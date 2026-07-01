import 'package:billing_baba/features/sales/models/payment_in_model.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
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

class PaginatedPaymentIn {
  const PaginatedPaymentIn({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  final List<PaymentInModel> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
}

List<PaymentInModel> _mockPaymentInRecords() {
  const parties = [
    'Abhivank',
    'Aashray Narang',
    'PartyAv',
    'naitik',
    'Sharma Traders',
    'Patel Electronics',
    'Gupta General Store',
    'Mehta Hardware',
    'Singh & Sons',
    'Kumar Agencies',
    'Reddy Mart',
    'Joshi Distributors',
  ];

  const paymentTypes = PaymentInDropdownOptions.paymentTypes;

  PaymentInModel buildRecord({
    required int id,
    required DateTime date,
    required PaymentInStatus status,
    int partyIndex = 0,
    double? amount,
  }) {
    final total = amount ?? (120 + (id * 137) % 50000).toDouble();
    final received = total;
    return PaymentInModel(
      id: '$id',
      receiptNo: id <= 3 ? '$id' : 'REC-${1773217264824 + id}',
      date: date,
      partyName: parties[partyIndex % parties.length],
      paymentType: paymentTypes[id % paymentTypes.length],
      status: status,
      totalAmount: total,
      receivedAmount: received,
      user: id % 3 == 0 ? 'Admin' : 'Staff',
      godown: id % 4 == 0 ? 'Main Location' : 'Warehouse B',
    );
  }

  return [
    buildRecord(
      id: 1,
      date: DateTime(2026, 3, 13, 17, 23),
      status: PaymentInStatus.used,
      amount: 120,
    ),
    buildRecord(
      id: 2,
      date: DateTime(2026, 3, 21, 17, 46),
      status: PaymentInStatus.used,
      partyIndex: 1,
      amount: 128,
    ),
    buildRecord(
      id: 3,
      date: DateTime(2026, 3, 25, 17, 54),
      status: PaymentInStatus.used,
      partyIndex: 2,
      amount: 20,
    ),
    buildRecord(
      id: 4,
      date: DateTime(2026, 2, 10, 14, 30),
      status: PaymentInStatus.unused,
      partyIndex: 3,
      amount: 2000000,
    ),
    buildRecord(
      id: 5,
      date: DateTime(2026, 1, 15, 11),
      status: PaymentInStatus.unused,
      partyIndex: 4,
      amount: 5000,
    ),
    ...List.generate(15, (index) {
      final id = index + 6;
      final month = (index % 6) + 1;
      final day = (index % 28) + 1;
      return buildRecord(
        id: id,
        date: DateTime(2026, month, day, 10 + (index % 8), index % 60),
        status: index.isEven
            ? PaymentInStatus.used
            : PaymentInStatus.unused,
        partyIndex: index + 4,
      );
    }),
  ];
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

String generateReceiptNo() {
  return 'REC-${DateTime.now().millisecondsSinceEpoch}';
}

@riverpod
class PaymentInRecords extends _$PaymentInRecords {
  @override
  List<PaymentInModel> build() => _mockPaymentInRecords();

  void addPayment(PaymentInModel payment) {
    state = [payment, ...state];
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

  void setUser(String user) {
    state = state.copyWith(selectedUser: user, currentPage: 1);
  }

  void setGodown(String godown) {
    state = state.copyWith(selectedGodown: godown, currentPage: 1);
  }

  void setStatus(String status) {
    state = state.copyWith(selectedStatus: status, currentPage: 1);
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }
}

@riverpod
List<PaymentInModel> filteredPaymentInRecords(Ref ref) {
  final records = ref.watch(paymentInRecordsProvider);
  final filters = ref.watch(paymentInFiltersProvider);

  final dateRange = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );
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
    if (dateRange != null &&
        !_isWithinRange(record.date, dateRange.start, dateRange.end)) {
      return false;
    }
    return true;
  }).toList();
}

@riverpod
PaginatedPaymentIn paginatedPaymentInRecords(Ref ref) {
  final filtered = ref.watch(filteredPaymentInRecordsProvider);
  final filters = ref.watch(paymentInFiltersProvider);

  final totalItems = filtered.length;
  final totalPages = totalItems == 0
      ? 1
      : (totalItems / paymentInPageSize).ceil();
  final currentPage = filters.currentPage.clamp(1, totalPages);
  final startIndex = (currentPage - 1) * paymentInPageSize;
  final endIndex = (startIndex + paymentInPageSize).clamp(0, totalItems);

  return PaginatedPaymentIn(
    items: filtered.sublist(startIndex, endIndex),
    currentPage: currentPage,
    totalPages: totalPages,
    totalItems: totalItems,
  );
}

@riverpod
PaymentInSummaryData paymentInSummary(Ref ref) {
  final records = ref.watch(filteredPaymentInRecordsProvider);
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
  });

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

  double get remainingBalance =>
      (balanceDue - receivedAmount - discount).clamp(0, double.infinity);

  bool get isValid => party.trim().isNotEmpty && receivedAmount > 0;

  PaymentInFormState copyWith({
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
  }) {
    return PaymentInFormState(
      party: party ?? this.party,
      paymentType: paymentType ?? this.paymentType,
      receiptNo: receiptNo ?? this.receiptNo,
      date: date ?? this.date,
      time: time ?? this.time,
      balanceDue: balanceDue ?? this.balanceDue,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      discount: discount ?? this.discount,
      description: description ?? this.description,
      showDescriptionField:
          showDescriptionField ?? this.showDescriptionField,
      showValidationErrors:
          showValidationErrors ?? this.showValidationErrors,
    );
  }
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

  void updateReceivedAmount(double value) {
    state = state.copyWith(receivedAmount: value);
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
      paymentType: state.paymentType,
      status: PaymentInStatus.unused,
      totalAmount: state.receivedAmount + state.discount,
      receivedAmount: state.receivedAmount,
      discount: state.discount,
      description: state.description,
    );
  }

  void savePayment() {
    final payment = buildPaymentModel();
    if (payment == null) return;
    ref.read(paymentInRecordsProvider.notifier).addPayment(payment);
    reset();
  }
}
