import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/payment_in_model.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_in_provider.g.dart';

const paymentInPageSize = 10;

abstract final class PaymentInDropdownOptions {
  static const paymentTypes = [
    'Cash',
    'Cheque',
    'Bank Transfer',
    'Online',
  ];
}

class PaymentInFiltersState {
  const PaymentInFiltersState({
    this.timeRangeOption = TimeRangeOption.allTime,
    this.customDateRange,
    this.selectedUser = 'All Users',
    this.selectedGodown = 'All Godown',
    this.selectedStatus = 'All Status',
    this.currentPage = 1,
  });

  final TimeRangeOption timeRangeOption;
  final DateTimeRange? customDateRange;
  final String selectedUser;
  final String selectedGodown;
  final String selectedStatus;
  final int currentPage;

  String get timeRangeLabel => timeRangeOption.label;

  PaymentInFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
    String? selectedUser,
    String? selectedGodown,
    String? selectedStatus,
    int? currentPage,
  }) {
    return PaymentInFiltersState(
      timeRangeOption: timeRangeOption ?? this.timeRangeOption,
      customDateRange: clearCustomDateRange
          ? null
          : (customDateRange ?? this.customDateRange),
      selectedUser: selectedUser ?? this.selectedUser,
      selectedGodown: selectedGodown ?? this.selectedGodown,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class PaymentInSummaryData {
  const PaymentInSummaryData({
    required this.totalAmount,
    required this.receivedAmount,
  });

  final double totalAmount;
  final double receivedAmount;
}

PaymentInStatus? _statusFromFilterLabel(String label) => switch (label) {
  'Used' => PaymentInStatus.used,
  'Unused' => PaymentInStatus.unused,
  _ => null,
};

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

PaymentListQuery _buildPaymentListQuery(PaymentInFiltersState filters) {
  final dateRange = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );

  return PaymentListQuery(
    page: filters.currentPage,
    limit: paymentInPageSize,
    direction: 'received',
    from: dateRange?.start.toUtc().toIso8601String(),
    to: dateRange?.end.toUtc().toIso8601String(),
  );
}

List<PaymentInModel> _applyClientFilters(
  List<PaymentInModel> records,
  PaymentInFiltersState filters,
) {
  final statusFilter = _statusFromFilterLabel(filters.selectedStatus);

  return records.where((record) {
    if (statusFilter != null && record.status != statusFilter) {
      return false;
    }
    if (filters.selectedUser != 'All Users' &&
        record.user != filters.selectedUser) {
      return false;
    }
    if (filters.selectedGodown != 'All Godown' &&
        record.godown != filters.selectedGodown) {
      return false;
    }
    return true;
  }).toList();
}

@Riverpod(keepAlive: true)
class PaymentInRecords extends _$PaymentInRecords {
  @override
  Future<PaginatedPaymentIn> build() async {
    ref.watch(paymentInFiltersProvider);
    return _fetchPage();
  }

  Future<PaginatedPaymentIn> _fetchPage() async {
    final filters = ref.read(paymentInFiltersProvider);
    final service = await ref.read(salesServiceProvider.future);
    final page = await service.fetchPaymentsPage(_buildPaymentListQuery(filters));

    return PaginatedPaymentIn(
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
class PaymentInFilters extends _$PaymentInFilters {
  @override
  PaymentInFiltersState build() => const PaymentInFiltersState();

  void setTimeRange(String label) {
    state = state.copyWith(
      timeRangeOption: TimeRangeOptionX.fromLabel(label),
      currentPage: 1,
    );
    ref.invalidate(paymentInRecordsProvider);
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
    ref.invalidate(paymentInRecordsProvider);
  }

  void setUser(String user) {
    state = state.copyWith(selectedUser: user, currentPage: 1);
    ref.invalidate(paymentInRecordsProvider);
  }

  void setGodown(String godown) {
    state = state.copyWith(selectedGodown: godown, currentPage: 1);
    ref.invalidate(paymentInRecordsProvider);
  }

  void setStatus(String status) {
    state = state.copyWith(selectedStatus: status, currentPage: 1);
    ref.invalidate(paymentInRecordsProvider);
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
    ref.invalidate(paymentInRecordsProvider);
  }
}

@riverpod
PaginatedPaymentIn paginatedPaymentInRecords(Ref ref) {
  final recordsAsync = ref.watch(paymentInRecordsProvider);
  return recordsAsync.maybeWhen(
    data: (page) => page,
    orElse: () => const PaginatedPaymentIn(
      items: [],
      currentPage: 1,
      totalPages: 1,
      totalItems: 0,
    ),
  );
}

@riverpod
PaymentInSummaryData paymentInSummary(Ref ref) {
  final page = ref.watch(paginatedPaymentInRecordsProvider);
  final records = page.items;
  final totalAmount = records.fold<double>(
    0,
    (sum, record) => sum + record.totalAmount,
  );
  final receivedAmount = records.fold<double>(
    0,
    (sum, record) => sum + record.receivedAmount,
  );

  return PaymentInSummaryData(
    totalAmount: totalAmount,
    receivedAmount: receivedAmount,
  );
}

class PaymentInFormState {
  const PaymentInFormState({
    this.partyId,
    this.party = '',
    this.paymentType = 'Cash',
    this.receiptNo = '',
    this.date,
    this.time,
    this.balanceDue = 0,
    this.receivedAmount = 0,
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
  final double receivedAmount;
  final double discount;
  final String description;
  final bool showDescriptionField;
  final bool showValidationErrors;
  final String? saveError;
  final bool isSaving;

  double get remainingBalance =>
      (balanceDue - receivedAmount - discount).clamp(0, double.infinity);

  bool get isValid =>
      party.trim().isNotEmpty &&
      partyId != null &&
      partyId!.isNotEmpty &&
      receivedAmount > 0;

  PaymentInFormState copyWith({
    String? partyId,
    String? party,
    String? paymentType,
    String? receiptNo,
    DateTime? date,
    TimeOfDay? time,
    double? balanceDue,
    double? receivedAmount,
    double? discount,
    String? description,
    bool? showDescriptionField,
    bool? showValidationErrors,
    String? saveError,
    bool clearSaveError = false,
    bool? isSaving,
  }) {
    return PaymentInFormState(
      partyId: partyId ?? this.partyId,
      party: party ?? this.party,
      paymentType: paymentType ?? this.paymentType,
      receiptNo: receiptNo ?? this.receiptNo,
      date: date ?? this.date,
      time: time ?? this.time,
      balanceDue: balanceDue ?? this.balanceDue,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      discount: discount ?? this.discount,
      description: description ?? this.description,
      showDescriptionField: showDescriptionField ?? this.showDescriptionField,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

String generateReceiptNo() {
  return 'REC-${DateTime.now().millisecondsSinceEpoch}';
}

PaymentInFormState _initialPaymentInFormState() {
  final now = DateTime.now();
  return PaymentInFormState(
    receiptNo: generateReceiptNo(),
    date: DateTime(now.year, now.month, now.day),
    time: TimeOfDay.fromDateTime(now),
  );
}

@riverpod
class PaymentInForm extends _$PaymentInForm {
  @override
  PaymentInFormState build() => _initialPaymentInFormState();

  void reset() {
    state = _initialPaymentInFormState();
  }

  Future<void> updateParty(String name, {String? partyId}) async {
    state = state.copyWith(
      party: name,
      partyId: partyId,
      clearSaveError: true,
    );

    if (partyId != null && partyId.isNotEmpty) {
      try {
        final service = await ref.read(salesServiceProvider.future);
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

  void updateReceivedAmount(double value) {
    state = state.copyWith(receivedAmount: value, clearSaveError: true);
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

  PaymentInModel? buildPaymentModel() {
    if (!state.isValid) {
      state = state.copyWith(showValidationErrors: true);
      return null;
    }

    final date = state.date ?? DateTime.now();
    final time = state.time ?? TimeOfDay.now();
    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    return PaymentInModel(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      receiptNo: state.receiptNo,
      date: dateTime,
      partyName: state.party.trim(),
      partyId: state.partyId,
      paymentType: state.paymentType,
      status: PaymentInStatus.unused,
      totalAmount: state.receivedAmount + state.discount,
      receivedAmount: state.receivedAmount,
      discount: state.discount,
      description: state.description,
    );
  }

  Future<({String? error, String? paymentId})> savePayment() async {
    final payment = buildPaymentModel();
    if (payment == null) {
      return (error: 'Please fill required fields', paymentId: null);
    }

    state = state.copyWith(isSaving: true, clearSaveError: true);

    try {
      final service = await ref.read(salesServiceProvider.future);
      final allocations = await service.buildFifoAllocations(
        partyId: state.partyId!,
        amount: payment.receivedAmount,
      );

      final created = await service.createPayment(
        CreatePaymentRequest(
          partyId: state.partyId!,
          direction: 'received',
          amount: payment.receivedAmount.toStringAsFixed(4),
          paymentMode: SalesPaymentModes.toApi(payment.paymentType),
          paymentDate: payment.date.toUtc().toIso8601String(),
          referenceNumber: payment.receiptNo,
          notes: payment.description.trim().isEmpty ? null : payment.description,
          allocations: allocations,
        ),
      );

      ref.invalidate(paymentInRecordsProvider);
      ref.invalidate(saleInvoicesProvider);
      refreshAfterPaymentIn(ref);
      final paymentId = created.id;
      reset();
      return (error: null, paymentId: paymentId);
    } catch (error) {
      final message = SalesErrorMapper.messageFor(error);
      state = state.copyWith(isSaving: false, saveError: message);
      return (error: message, paymentId: null);
    }
  }
}
