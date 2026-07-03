import 'package:billing_baba/features/purchases/models/payment_out_model.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_out_provider.g.dart';

const paymentOutPageSize = 10;

abstract final class PaymentOutDropdownOptions {
  static const paymentTypes = [
    'Cash',
    'Cheque',
    'Bank Transfer',
    'Online',
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

class PaginatedPaymentOut {
  const PaginatedPaymentOut({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  final List<PaymentOutModel> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
}

List<PaymentOutModel> _mockPaymentOutRecords() {
  const parties = ['KK INDUSTRIES', 'Sharma Traders', 'Patel Electronics'];
  const paymentTypes = ['Cash', 'Cheque', 'Bank Transfer', 'UPI'];

  return List.generate(8, (index) {
    final id = index + 1;
    final total = (5000 + id * 1200).toDouble();
    final paid = index % 3 == 0 ? total * 0.5 : total;
    return PaymentOutModel(
      id: '$id',
      receiptNo: 'PO-${1000 + id}',
      date: DateTime(2026, 7, id * 2, 10 + index, index * 5),
      partyName: parties[index % parties.length],
      paymentType: paymentTypes[index % paymentTypes.length],
      status: index % 3 == 0 ? PaymentOutStatus.pending : PaymentOutStatus.paid,
      totalAmount: total,
      paidAmount: paid,
      user: index.isEven ? 'Admin' : 'Staff',
      firm: index.isEven ? 'Main Firm' : 'Branch Firm',
    );
  });
}

DateTime _startOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);

DateTime _endOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

bool _isWithinRange(DateTime date, DateTime start, DateTime end) {
  final normalized = _startOfDay(date);
  return !normalized.isBefore(_startOfDay(start)) &&
      !normalized.isAfter(_startOfDay(end));
}

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

@riverpod
class PaymentOutRecords extends _$PaymentOutRecords {
  @override
  List<PaymentOutModel> build() => _mockPaymentOutRecords();

  void addPayment(PaymentOutModel payment) {
    state = [payment, ...state];
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
  }

  void setFirm(String firm) {
    state = state.copyWith(selectedFirm: firm, currentPage: 1);
  }

  void setUser(String user) {
    state = state.copyWith(selectedUser: user, currentPage: 1);
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }
}

@riverpod
List<PaymentOutModel> filteredPaymentOutRecords(Ref ref) {
  final records = ref.watch(paymentOutRecordsProvider);
  final filters = ref.watch(paymentOutFiltersProvider);

  final dateRange = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );

  return records.where((record) {
    if (filters.selectedFirm != 'All Firms' &&
        record.firm != filters.selectedFirm) {
      return false;
    }
    if (filters.selectedUser != 'All Users' &&
        record.user != filters.selectedUser) {
      return false;
    }
    if (dateRange != null &&
        !_isWithinRange(record.date, dateRange.start, dateRange.end)) {
      return false;
    }
    return true;
  }).toList();
}

@riverpod
PaginatedPaymentOut paginatedPaymentOutRecords(Ref ref) {
  final filtered = ref.watch(filteredPaymentOutRecordsProvider);
  final filters = ref.watch(paymentOutFiltersProvider);

  final totalItems = filtered.length;
  final totalPages = totalItems == 0
      ? 1
      : (totalItems / paymentOutPageSize).ceil();
  final currentPage = filters.currentPage.clamp(1, totalPages);
  final startIndex = (currentPage - 1) * paymentOutPageSize;
  final endIndex = (startIndex + paymentOutPageSize).clamp(0, totalItems);

  return PaginatedPaymentOut(
    items: filtered.sublist(startIndex, endIndex),
    currentPage: currentPage,
    totalPages: totalPages,
    totalItems: totalItems,
  );
}

@riverpod
PaymentOutSummaryData paymentOutSummary(Ref ref) {
  final records = ref.watch(filteredPaymentOutRecordsProvider);
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
    this.party = '',
    this.paymentType = 'Cash',
    this.receiptNo = '',
    this.date,
    this.time,
    this.paidAmount = 0,
    this.discount = 0,
    this.description = '',
    this.showDescriptionField = false,
    this.showValidationErrors = false,
  });

  final String party;
  final String paymentType;
  final String receiptNo;
  final DateTime? date;
  final TimeOfDay? time;
  final double paidAmount;
  final double discount;
  final String description;
  final bool showDescriptionField;
  final bool showValidationErrors;

  double get total => (paidAmount - discount).clamp(0, double.infinity);

  bool get isValid => party.trim().isNotEmpty && paidAmount > 0;

  PaymentOutFormState copyWith({
    String? party,
    String? paymentType,
    String? receiptNo,
    DateTime? date,
    TimeOfDay? time,
    double? paidAmount,
    double? discount,
    String? description,
    bool? showDescriptionField,
    bool? showValidationErrors,
  }) {
    return PaymentOutFormState(
      party: party ?? this.party,
      paymentType: paymentType ?? this.paymentType,
      receiptNo: receiptNo ?? this.receiptNo,
      date: date ?? this.date,
      time: time ?? this.time,
      paidAmount: paidAmount ?? this.paidAmount,
      discount: discount ?? this.discount,
      description: description ?? this.description,
      showDescriptionField: showDescriptionField ?? this.showDescriptionField,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
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

  void updateParty(String value) {
    state = state.copyWith(party: value);
  }

  void updatePaymentType(String value) {
    state = state.copyWith(paymentType: value);
  }

  void updateDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void updateTime(TimeOfDay time) {
    state = state.copyWith(time: time);
  }

  void updatePaidAmount(double value) {
    state = state.copyWith(paidAmount: value);
  }

  void updateDiscount(double value) {
    state = state.copyWith(discount: value);
  }

  void updateDescription(String value) {
    state = state.copyWith(description: value);
  }

  void toggleDescriptionField() {
    state = state.copyWith(showDescriptionField: !state.showDescriptionField);
  }

  PaymentOutModel? buildPaymentModel() {
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

    return PaymentOutModel(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      receiptNo: state.receiptNo,
      date: dateTime,
      partyName: state.party.trim(),
      paymentType: state.paymentType,
      status: PaymentOutStatus.paid,
      totalAmount: state.total,
      paidAmount: state.paidAmount,
      discount: state.discount,
      description: state.description,
    );
  }

  void savePayment() {
    final payment = buildPaymentModel();
    if (payment == null) return;
    ref.read(paymentOutRecordsProvider.notifier).addPayment(payment);
    reset();
  }
}
