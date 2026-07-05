import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/application/purchase_service.dart';
import 'package:billing_baba/features/purchases/models/payment_out_model.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';
import 'package:billing_baba/features/purchases/providers/purchase_bills_provider.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_out_provider.g.dart';

const paymentOutPageSize = 10;

abstract final class PaymentOutDropdownOptions {
  static const paymentTypes = [
    'Cash',
    'UPI',
    'Cheque',
    'Bank Transfer',
    'Card',
    'Wallet',
    'Others',
  ];
}

String generatePaymentOutReceiptNo() {
  return 'PO-${DateTime.now().millisecondsSinceEpoch}';
}

class PaymentOutFiltersState {
  const PaymentOutFiltersState({
    this.timeRangeOption = TimeRangeOption.thisMonth,
    this.customDateRange,
    this.selectedFirm = 'All Firms',
    this.selectedUser = 'All Users',
    this.currentPage = 1,
  });

  final TimeRangeOption timeRangeOption;
  final DateTimeRange? customDateRange;
  final String selectedFirm;
  final String selectedUser;
  final int currentPage;

  String get timeRangeLabel => timeRangeOption.label;

  PaymentOutFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
    String? selectedFirm,
    String? selectedUser,
    int? currentPage,
  }) {
    return PaymentOutFiltersState(
      timeRangeOption: timeRangeOption ?? this.timeRangeOption,
      customDateRange: clearCustomDateRange
          ? null
          : (customDateRange ?? this.customDateRange),
      selectedFirm: selectedFirm ?? this.selectedFirm,
      selectedUser: selectedUser ?? this.selectedUser,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class PaymentOutSummaryData {
  const PaymentOutSummaryData({
    required this.totalAmount,
    required this.paidAmount,
  });

  final double totalAmount;
  final double paidAmount;
}

DateTime _startOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);

DateTime _endOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

DateTimeRange? _resolveTimeRange(
  TimeRangeOption option,
  DateTimeRange? custom,
) {
  final now = DateTime.now();
  final today = _startOfDay(now);

  return switch (option) {
    TimeRangeOption.allTime => null,
    TimeRangeOption.today => DateTimeRange(start: today, end: _endOfDay(today)),
    TimeRangeOption.thisWeek => DateTimeRange(
      start: today.subtract(Duration(days: today.weekday % 7)),
      end: _endOfDay(
        today.add(Duration(days: 6 - (today.weekday % 7))),
      ),
    ),
    TimeRangeOption.thisMonth => DateTimeRange(
      start: DateTime(now.year, now.month),
      end: _endOfDay(DateTime(now.year, now.month + 1, 0)),
    ),
    TimeRangeOption.thisYear => DateTimeRange(
      start: DateTime(now.year),
      end: _endOfDay(DateTime(now.year, 12, 31)),
    ),
    TimeRangeOption.custom => custom,
  };
}

PaymentListQuery _buildPaymentListQuery(PaymentOutFiltersState filters) {
  final dateRange = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );

  return PaymentListQuery(
    page: filters.currentPage,
    limit: paymentOutPageSize,
    direction: 'paid',
    from: dateRange?.start.toUtc().toIso8601String(),
    to: dateRange?.end.toUtc().toIso8601String(),
  );
}

List<PaymentOutModel> _applyClientFilters(
  List<PaymentOutModel> records,
  PaymentOutFiltersState filters,
) {
  return records.where((record) {
    if (filters.selectedFirm != 'All Firms' &&
        record.firm != filters.selectedFirm) {
      return false;
    }
    if (filters.selectedUser != 'All Users' &&
        record.user != filters.selectedUser) {
      return false;
    }
    return true;
  }).toList();
}

@Riverpod(keepAlive: true)
class PaymentOutRecords extends _$PaymentOutRecords {
  @override
  Future<PaginatedPaymentOut> build() async {
    ref.watch(paymentOutFiltersProvider);
    return _fetchPage();
  }

  Future<PaginatedPaymentOut> _fetchPage() async {
    final filters = ref.read(paymentOutFiltersProvider);
    final service = await ref.read(purchaseServiceProvider.future);
    final page = await service.fetchPaymentsPage(_buildPaymentListQuery(filters));

    return PaginatedPaymentOut(
      items: _applyClientFilters(page.items, filters),
      currentPage: page.currentPage,
      totalPages: page.totalPages,
      totalItems: page.totalItems,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchPage);
  }
}

@riverpod
class PaymentOutFilters extends _$PaymentOutFilters {
  @override
  PaymentOutFiltersState build() => const PaymentOutFiltersState();

  void setTimeRange(String label) {
    state = state.copyWith(
      timeRangeOption: TimeRangeOptionX.fromLabel(label),
      currentPage: 1,
    );
    ref.invalidate(paymentOutRecordsProvider);
  }

  void setCustomDateRange(
    DateTimeRange range, {
    bool autoSwitchToCustom = false,
  }) {
    state = state.copyWith(
      timeRangeOption: autoSwitchToCustom
          ? TimeRangeOption.custom
          : state.timeRangeOption,
      customDateRange: range,
      currentPage: 1,
    );
    ref.invalidate(paymentOutRecordsProvider);
  }

  void setFirm(String firm) {
    state = state.copyWith(selectedFirm: firm, currentPage: 1);
    ref.invalidate(paymentOutRecordsProvider);
  }

  void setUser(String user) {
    state = state.copyWith(selectedUser: user, currentPage: 1);
    ref.invalidate(paymentOutRecordsProvider);
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
    ref.invalidate(paymentOutRecordsProvider);
  }
}

@riverpod
PaginatedPaymentOut paginatedPaymentOutRecords(Ref ref) {
  final recordsAsync = ref.watch(paymentOutRecordsProvider);
  return recordsAsync.maybeWhen(
    data: (page) => page,
    orElse: () => const PaginatedPaymentOut(
      items: [],
      currentPage: 1,
      totalPages: 1,
      totalItems: 0,
    ),
  );
}

@riverpod
PaymentOutSummaryData paymentOutSummary(Ref ref) {
  final page = ref.watch(paginatedPaymentOutRecordsProvider);
  final records = page.items;
  final totalAmount = records.fold<double>(
    0,
    (sum, record) => sum + record.totalAmount,
  );
  final paidAmount = records.fold<double>(
    0,
    (sum, record) => sum + record.paidAmount,
  );

  return PaymentOutSummaryData(
    totalAmount: totalAmount,
    paidAmount: paidAmount,
  );
}

class PaymentOutFormState {
  const PaymentOutFormState({
    this.partyId,
    this.party = '',
    this.paymentType = 'Cash',
    this.receiptNo = '',
    this.date,
    this.time,
    this.balanceDue = 0,
    this.paidAmount = 0,
    this.discount = 0,
    this.description = '',
    this.showDescriptionField = false,
    this.showValidationErrors = false,
    this.saveError,
    this.isSaving = false,
  });

  final String? partyId;
  final String party;
  final String paymentType;
  final String receiptNo;
  final DateTime? date;
  final TimeOfDay? time;
  final double balanceDue;
  final double paidAmount;
  final double discount;
  final String description;
  final bool showDescriptionField;
  final bool showValidationErrors;
  final String? saveError;
  final bool isSaving;

  double get total => (paidAmount - discount).clamp(0, double.infinity);

  bool get isValid =>
      party.trim().isNotEmpty &&
      partyId != null &&
      partyId!.isNotEmpty &&
      paidAmount > 0;

  PaymentOutFormState copyWith({
    String? partyId,
    String? party,
    String? paymentType,
    String? receiptNo,
    DateTime? date,
    TimeOfDay? time,
    double? balanceDue,
    double? paidAmount,
    double? discount,
    String? description,
    bool? showDescriptionField,
    bool? showValidationErrors,
    String? saveError,
    bool clearSaveError = false,
    bool? isSaving,
  }) {
    return PaymentOutFormState(
      partyId: partyId ?? this.partyId,
      party: party ?? this.party,
      paymentType: paymentType ?? this.paymentType,
      receiptNo: receiptNo ?? this.receiptNo,
      date: date ?? this.date,
      time: time ?? this.time,
      balanceDue: balanceDue ?? this.balanceDue,
      paidAmount: paidAmount ?? this.paidAmount,
      discount: discount ?? this.discount,
      description: description ?? this.description,
      showDescriptionField: showDescriptionField ?? this.showDescriptionField,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

PaymentOutFormState _initialPaymentOutFormState() {
  final now = DateTime.now();
  return PaymentOutFormState(
    receiptNo: generatePaymentOutReceiptNo(),
    date: DateTime(now.year, now.month, now.day),
    time: TimeOfDay.fromDateTime(now),
  );
}

@riverpod
class PaymentOutForm extends _$PaymentOutForm {
  @override
  PaymentOutFormState build() => _initialPaymentOutFormState();

  void reset() {
    state = _initialPaymentOutFormState();
  }

  Future<void> updateParty(String name, {String? partyId}) async {
    state = state.copyWith(
      party: name,
      partyId: partyId,
      clearSaveError: true,
    );

    if (partyId != null && partyId.isNotEmpty) {
      try {
        final service = await ref.read(purchaseServiceProvider.future);
        final balanceDue = await service.fetchPartyBalanceDue(partyId);
        state = state.copyWith(balanceDue: balanceDue);
      } catch (_) {
        // Balance lookup is best-effort for the dialog.
      }
    }
  }

  void updatePaymentType(String value) {
    state = state.copyWith(paymentType: value, clearSaveError: true);
  }

  void updateDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void updateTime(TimeOfDay time) {
    state = state.copyWith(time: time);
  }

  void updatePaidAmount(double value) {
    state = state.copyWith(paidAmount: value, clearSaveError: true);
  }

  void updateDiscount(double value) {
    state = state.copyWith(discount: value, clearSaveError: true);
  }

  void updateDescription(String value) {
    state = state.copyWith(description: value);
  }

  void toggleDescriptionField() {
    state = state.copyWith(showDescriptionField: !state.showDescriptionField);
  }

  Future<({String? error, String? paymentId})> savePayment() async {
    if (!state.isValid) {
      state = state.copyWith(showValidationErrors: true);
      return (error: 'Please fill required fields', paymentId: null);
    }

    state = state.copyWith(isSaving: true, clearSaveError: true);

    try {
      final service = await ref.read(purchaseServiceProvider.future);
      final date = state.date ?? DateTime.now();
      final time = state.time ?? TimeOfDay.now();
      final paymentDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      final allocations = await service.buildFifoAllocations(
        partyId: state.partyId!,
        amount: state.paidAmount,
      );

      final created = await service.createPayment(
        CreatePaymentRequest(
          partyId: state.partyId!,
          direction: 'paid',
          amount: state.paidAmount.toStringAsFixed(4),
          paymentMode: PurchasePaymentModes.toApi(state.paymentType),
          paymentDate: paymentDate.toUtc().toIso8601String(),
          referenceNumber: state.receiptNo,
          notes: state.description.trim().isEmpty ? null : state.description,
          allocations: allocations,
        ),
      );

      ref.invalidate(paymentOutRecordsProvider);
      ref.invalidate(purchaseBillsProvider);
      final paymentId = created.id;
      reset();
      return (error: null, paymentId: paymentId);
    } catch (error) {
      final message = PurchaseErrorMapper.messageFor(error);
      state = state.copyWith(isSaving: false, saveError: message);
      return (error: message, paymentId: null);
    }
  }
}
