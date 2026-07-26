import 'package:billing_baba/shared/attachments/document_attachment_entity_type.dart';
import 'package:billing_baba/shared/attachments/transaction_attachment_actions.dart';
import 'package:billing_baba/shared/forms/transaction_form_validation.dart';
import 'package:billing_baba/shared/forms/transaction_party_link.dart';
import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/shared/utils/debouncer.dart';
import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/hidden_ledger/application/hidden_ledger_service.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/sales/application/sale_invoices_provider.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/payment_in_model.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:billing_baba/features/settings/services/whatsapp_auto_notify.dart';
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    this.timeRangeOption = TimeRangeOption.thisMonth,
    this.customDateRange,
    this.partyId,
    this.dateColumnFilter,
    this.refNoColumnFilter,
    this.partyNameColumnFilter,
    this.totalAmountColumnFilter,
    this.receivedAmountColumnFilter,
    this.paymentTypeColumnFilter,
    this.selectedFirm = 'All Firms',
    this.selectedUser = 'All Users',
    this.selectedStatus = 'All Status',
    this.searchQuery = '',
    this.currentPage = 1,
  });

  final TimeRangeOption timeRangeOption;
  final DateTimeRange? customDateRange;
  final String? partyId;
  final DateColumnFilter? dateColumnFilter;
  final TextColumnFilter? refNoColumnFilter;
  final TextColumnFilter? partyNameColumnFilter;
  final AmountColumnFilter? totalAmountColumnFilter;
  final AmountColumnFilter? receivedAmountColumnFilter;
  final SelectColumnFilter? paymentTypeColumnFilter;
  final String selectedFirm;
  final String selectedUser;
  final String selectedStatus;
  final String searchQuery;
  final int currentPage;

  String get timeRangeLabel => timeRangeOption.label;

  PaymentInFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
    String? partyId,
    bool clearPartyId = false,
    DateColumnFilter? dateColumnFilter,
    bool clearDateColumnFilter = false,
    TextColumnFilter? refNoColumnFilter,
    bool clearRefNoColumnFilter = false,
    TextColumnFilter? partyNameColumnFilter,
    bool clearPartyNameColumnFilter = false,
    AmountColumnFilter? totalAmountColumnFilter,
    bool clearTotalAmountColumnFilter = false,
    AmountColumnFilter? receivedAmountColumnFilter,
    bool clearReceivedAmountColumnFilter = false,
    SelectColumnFilter? paymentTypeColumnFilter,
    bool clearPaymentTypeColumnFilter = false,
    String? selectedFirm,
    String? selectedUser,
    String? selectedStatus,
    String? searchQuery,
    int? currentPage,
  }) {
    return PaymentInFiltersState(
      timeRangeOption: timeRangeOption ?? this.timeRangeOption,
      customDateRange: clearCustomDateRange
          ? null
          : (customDateRange ?? this.customDateRange),
      partyId: clearPartyId ? null : (partyId ?? this.partyId),
      dateColumnFilter: clearDateColumnFilter
          ? null
          : (dateColumnFilter ?? this.dateColumnFilter),
      refNoColumnFilter: clearRefNoColumnFilter
          ? null
          : (refNoColumnFilter ?? this.refNoColumnFilter),
      partyNameColumnFilter: clearPartyNameColumnFilter
          ? null
          : (partyNameColumnFilter ?? this.partyNameColumnFilter),
      totalAmountColumnFilter: clearTotalAmountColumnFilter
          ? null
          : (totalAmountColumnFilter ?? this.totalAmountColumnFilter),
      receivedAmountColumnFilter: clearReceivedAmountColumnFilter
          ? null
          : (receivedAmountColumnFilter ?? this.receivedAmountColumnFilter),
      paymentTypeColumnFilter: clearPaymentTypeColumnFilter
          ? null
          : (paymentTypeColumnFilter ?? this.paymentTypeColumnFilter),
      selectedFirm: selectedFirm ?? this.selectedFirm,
      selectedUser: selectedUser ?? this.selectedUser,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

bool needsPaymentInClientSideFiltering(PaymentInFiltersState filters) {
  return filters.hasColumnFilters ||
      filters.selectedStatus != 'All Status' ||
      filters.selectedUser != 'All Users' ||
      filters.selectedFirm != 'All Firms' ||
      filters.searchQuery.trim().isNotEmpty;
}

extension on PaymentInFiltersState {
  bool get hasColumnFilters =>
      dateColumnFilter != null ||
      refNoColumnFilter != null ||
      partyNameColumnFilter != null ||
      totalAmountColumnFilter != null ||
      receivedAmountColumnFilter != null ||
      paymentTypeColumnFilter != null;
}

PaymentInStatus? _statusFromFilterLabel(String label) => switch (label) {
  'Paid' => PaymentInStatus.paid,
  'Partial' => PaymentInStatus.partial,
  'Unpaid' => PaymentInStatus.unused,
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

PaymentListQuery _buildFetchAllQuery(PaymentInFiltersState filters) {
  final dateRange = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );

  return PaymentListQuery(
    limit: PaginatedFetch.defaultPageSize,
    direction: 'received',
    partyId: filters.partyId,
    from: dateRange?.start.toUtc().toIso8601String(),
    to: dateRange?.end.toUtc().toIso8601String(),
  );
}

PaginatedPaymentIn _allPaymentInPage(List<PaymentInModel> records) {
  return PaginatedPaymentIn(
    items: records,
    currentPage: 1,
    totalPages: 1,
    totalItems: records.length,
  );
}

PaymentInSummaryData _computePaymentInSummary(List<PaymentInModel> records) {
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
    growthPercent: totalAmount > 0 ? 100 : 0,
  );
}

List<PaymentInModel> _applyClientFilters(
  List<PaymentInModel> records,
  PaymentInFiltersState filters,
) {
  final statusFilter = _statusFromFilterLabel(filters.selectedStatus);
  final search = filters.searchQuery.trim().toLowerCase();

  return records.where((record) {
    if (statusFilter != null && record.status != statusFilter) {
      return false;
    }
    if (filters.selectedFirm != 'All Firms' &&
        record.firm != filters.selectedFirm) {
      return false;
    }
    if (filters.selectedUser != 'All Users' &&
        record.user != filters.selectedUser) {
      return false;
    }
    if (filters.dateColumnFilter != null &&
        !filters.dateColumnFilter!.matches(record.date)) {
      return false;
    }
    if (filters.refNoColumnFilter != null &&
        !filters.refNoColumnFilter!.matches(record.receiptNo)) {
      return false;
    }
    if (filters.partyNameColumnFilter != null &&
        !filters.partyNameColumnFilter!.matches(record.partyName)) {
      return false;
    }
    if (filters.totalAmountColumnFilter != null &&
        !filters.totalAmountColumnFilter!.matches(record.totalAmount)) {
      return false;
    }
    if (filters.receivedAmountColumnFilter != null &&
        !filters.receivedAmountColumnFilter!.matches(record.receivedAmount)) {
      return false;
    }
    if (filters.paymentTypeColumnFilter != null &&
        !filters.paymentTypeColumnFilter!.matches(record.paymentType)) {
      return false;
    }
    if (search.isNotEmpty) {
      final haystack =
          '${record.partyName} ${record.receiptNo} ${record.paymentType}'
              .toLowerCase();
      if (!haystack.contains(search)) {
        return false;
      }
    }
    return true;
  }).toList();
}

PaginatedPaymentIn _paginatePaymentInRecords(
  List<PaymentInModel> records,
  int currentPage,
) {
  if (records.isEmpty) {
    return const PaginatedPaymentIn(
      items: [],
      currentPage: 1,
      totalPages: 1,
      totalItems: 0,
    );
  }

  final totalItems = records.length;
  final totalPages = (totalItems / paymentInPageSize).ceil();
  final page = currentPage.clamp(1, totalPages);
  final start = (page - 1) * paymentInPageSize;
  final end = (start + paymentInPageSize).clamp(0, totalItems);

  return PaginatedPaymentIn(
    items: records.sublist(start, end),
    currentPage: page,
    totalPages: totalPages,
    totalItems: totalItems,
  );
}

@Riverpod(keepAlive: true)
class PaymentInRecords extends _$PaymentInRecords {
  @override
  Future<PaginatedPaymentIn> build() async {
    ref.watch(
      paymentInFiltersProvider.select(
        (filters) => (
          filters.timeRangeOption,
          filters.customDateRange,
          filters.partyId,
        ),
      ),
    );
    final allRecords = await _fetchAllRecords();
    return _allPaymentInPage(allRecords);
  }

  Future<List<PaymentInModel>> _fetchAllRecords() async {
    final filters = ref.read(paymentInFiltersProvider);
    final service = await ref.read(salesServiceProvider.future);
    final partyNames = await service.fetchPartyNameMap();
    final baseQuery = _buildFetchAllQuery(filters);

    return PaginatedFetch.fetchAll<PaymentInModel>(
      fetchPage: (page) async {
        final pageResult = await service.fetchPaymentsPage(
          PaymentListQuery(
            page: page,
            limit: baseQuery.limit,
            direction: baseQuery.direction,
            partyId: baseQuery.partyId,
            from: baseQuery.from,
            to: baseQuery.to,
          ),
          partyNames: partyNames,
        );
        return (items: pageResult.items, totalPages: pageResult.totalPages);
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final allRecords = await _fetchAllRecords();
      return _allPaymentInPage(allRecords);
    });
  }

  Future<String?> deletePayment(String paymentId) async {
    try {
      final service = await ref.read(salesServiceProvider.future);
      await service.deletePayment(paymentId);
      refreshAfterPaymentIn(ref);
      return null;
    } catch (error) {
      return SalesErrorMapper.messageFor(error);
    }
  }
}

@riverpod
class PaymentInFilters extends _$PaymentInFilters {
  Debouncer? _searchDebouncer;

  @override
  PaymentInFiltersState build() {
    ref.onDispose(() => _searchDebouncer?.dispose());
    return const PaymentInFiltersState();
  }

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

  void setFirm(String firm) {
    state = state.copyWith(selectedFirm: firm, currentPage: 1);
  }

  void setStatus(String status) {
    state = state.copyWith(selectedStatus: status, currentPage: 1);
  }

  void setSearchQuery(String query) {
    _searchDebouncer ??= Debouncer();
    _searchDebouncer!.run(() {
      state = state.copyWith(searchQuery: query, currentPage: 1);
    });
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void setPartyFilter({String? partyId, String? partyName}) {
    state = state.copyWith(
      partyId: partyId,
      clearPartyId: partyId == null,
      currentPage: 1,
    );
  }

  void setDateColumnFilter(DateColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearDateColumnFilter: true, currentPage: 1)
        : state.copyWith(dateColumnFilter: filter, currentPage: 1);
  }

  void setRefNoColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearRefNoColumnFilter: true, currentPage: 1)
        : state.copyWith(refNoColumnFilter: filter, currentPage: 1);
  }

  void setPartyNameColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPartyNameColumnFilter: true, currentPage: 1)
        : state.copyWith(partyNameColumnFilter: filter, currentPage: 1);
  }

  void setTotalAmountColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearTotalAmountColumnFilter: true, currentPage: 1)
        : state.copyWith(totalAmountColumnFilter: filter, currentPage: 1);
  }

  void setReceivedAmountColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearReceivedAmountColumnFilter: true, currentPage: 1)
        : state.copyWith(receivedAmountColumnFilter: filter, currentPage: 1);
  }

  void setPaymentTypeColumnFilter(SelectColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPaymentTypeColumnFilter: true, currentPage: 1)
        : state.copyWith(paymentTypeColumnFilter: filter, currentPage: 1);
  }
}

@riverpod
List<PaymentInModel> filteredPaymentInRecords(Ref ref) {
  final allRecords =
      ref.watch(paymentInRecordsProvider).value?.items ?? const [];
  final filters = ref.watch(paymentInFiltersProvider);
  return _applyClientFilters(allRecords, filters);
}

@riverpod
PaginatedPaymentIn paginatedPaymentInRecords(Ref ref) {
  final filtered = ref.watch(filteredPaymentInRecordsProvider);
  final filters = ref.watch(paymentInFiltersProvider);
  return _paginatePaymentInRecords(filtered, filters.currentPage);
}

@riverpod
PaymentInSummaryData paymentInSummary(Ref ref) {
  final records = ref.watch(filteredPaymentInRecordsProvider);
  return _computePaymentInSummary(records);
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
    this.attachedImages = const [],
    this.attachedDocuments = const [],
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
  final List<SaleFormAttachment> attachedImages;
  final List<SaleFormAttachment> attachedDocuments;
  final bool showValidationErrors;
  final String? saveError;
  final bool isSaving;

  double get remainingBalance =>
      (balanceDue - receivedAmount - discount).clamp(0, double.infinity);

  bool get hasShortPayment =>
      receivedAmount + discount < balanceDue && balanceDue > 0;

  bool get isValid =>
      party.trim().isNotEmpty &&
      partyId != null &&
      partyId!.isNotEmpty &&
      receivedAmount > 0;

  bool get partyHasError => transactionPartyHasError(
    showValidationErrors: showValidationErrors,
    partyId: partyId,
    partyName: party,
  );

  bool get amountHasError => transactionAmountHasError(
    showValidationErrors: showValidationErrors,
    amount: receivedAmount,
  );

  PaymentInFormState copyWith({
    String? partyId,
    bool clearPartyId = false,
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
    List<SaleFormAttachment>? attachedImages,
    List<SaleFormAttachment>? attachedDocuments,
    bool? showValidationErrors,
    String? saveError,
    bool clearSaveError = false,
    bool? isSaving,
  }) {
    return PaymentInFormState(
      partyId: clearPartyId ? null : (partyId ?? this.partyId),
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
      attachedImages: attachedImages ?? this.attachedImages,
      attachedDocuments: attachedDocuments ?? this.attachedDocuments,
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

  Future<void> loadPaymentAttachmentsForEdit(String paymentId) async {
    if (state.attachedImages.isNotEmpty ||
        state.attachedDocuments.isNotEmpty) {
      return;
    }

    final attachments = await loadTransactionAttachments(
      ref,
      entityType: DocumentAttachmentEntityType.paymentIn.apiValue,
      entityId: paymentId,
    );
    state = state.copyWith(
      attachedImages: attachments.images,
      attachedDocuments: attachments.documents,
    );
  }

  Future<void> updateParty(String name, {String? partyId}) async {
    final change = unlinkedPartyNameChange(
      newName: name,
      previousName: state.party,
      currentPartyId: state.partyId,
    );
    final clearLink = partyId == null && change.clearPartyId;
    state = state.copyWith(
      party: change.partyName,
      partyId: partyId,
      clearPartyId: clearLink,
      clearSaveError: true,
      balanceDue: clearLink ? 0 : state.balanceDue,
    );

    if (partyId != null && partyId.isNotEmpty) {
      await refreshBalanceDue();
    } else {
      state = state.copyWith(balanceDue: 0);
    }
  }

  /// Loads the party's official receivable balance for short-payment detection.
  Future<void> refreshBalanceDue() async {
    final partyId = state.partyId;
    if (partyId == null || partyId.isEmpty) return;

    try {
      final partyService = await ref.read(partyServiceProvider.future);
      final party = await partyService.getParty(partyId);
      if (party.hasReceivable) {
        state = state.copyWith(balanceDue: party.balance);
        return;
      }

      final salesService = await ref.read(salesServiceProvider.future);
      final invoiceBalance = await salesService.fetchPartyBalanceDue(partyId);
      state = state.copyWith(balanceDue: invoiceBalance);
    } catch (_) {
      // Balance lookup is best-effort for the dialog.
    }
  }

  String? _validationError() {
    return buildTransactionValidationError(
      hasValidLineItems: true,
      hasValidParty: state.partyId != null && state.partyId!.isNotEmpty,
      hasValidAmount: state.receivedAmount > 0,
      requireParty: true,
      requireAmount: true,
    );
  }

  void updatePaymentType(String value) {
    state = state.copyWith(paymentType: value, clearSaveError: true);
  }

  void updateReceiptNo(String value) {
    state = state.copyWith(receiptNo: value, clearSaveError: true);
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

  void addImage(SaleFormAttachment attachment) {
    state = state.copyWith(
      attachedImages: [...state.attachedImages, attachment],
    );
  }

  void removeImage(String id) {
    state = state.copyWith(
      attachedImages: state.attachedImages.where((item) => item.id != id).toList(),
    );
  }

  void updateImage(String id, String name) {
    state = state.copyWith(
      attachedImages: [
        for (final image in state.attachedImages)
          if (image.id == id) image.copyWith(name: name) else image,
      ],
    );
  }

  void addDocument(SaleFormAttachment attachment) {
    state = state.copyWith(
      attachedDocuments: [...state.attachedDocuments, attachment],
    );
  }

  void removeDocument(String id) {
    state = state.copyWith(
      attachedDocuments:
          state.attachedDocuments.where((item) => item.id != id).toList(),
    );
  }

  void updateDocument(String id, String name) {
    state = state.copyWith(
      attachedDocuments: [
        for (final document in state.attachedDocuments)
          if (document.id == id) document.copyWith(name: name) else document,
      ],
    );
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

  Future<({String? error, String? paymentId})> savePayment({
    String? shortPaymentHandling,
    double? shortfallAmount,
  }) async {
    if (state.isSaving) {
      return (error: null, paymentId: null);
    }

    final payment = buildPaymentModel();
    if (payment == null) {
      return (error: _validationError(), paymentId: null);
    }

    state = state.copyWith(isSaving: true, clearSaveError: true);

    try {
      final service = await ref.read(salesServiceProvider.future);
      final allocations = await service.buildFifoAllocations(
        partyId: state.partyId!,
        amount: payment.receivedAmount,
      );

      final balanceAfterPayment = (state.balanceDue -
              payment.receivedAmount -
              payment.discount)
          .clamp(0, double.infinity);

      final created = await service.createPayment(
        CreatePaymentRequest(
          partyId: state.partyId!,
          direction: 'received',
          amount: payment.receivedAmount.toStringAsFixed(4),
          paymentMode: SalesPaymentModes.toApi(payment.paymentType),
          paymentDate: payment.date.toUtc().toIso8601String(),
          referenceNumber: payment.receiptNo,
          notes: payment.description.trim().isEmpty
              ? null
              : payment.description,
          discountAmount: payment.discount > 0
              ? payment.discount.toStringAsFixed(4)
              : null,
          balanceAfterPayment: payment.discount > 0
              ? balanceAfterPayment.toStringAsFixed(4)
              : null,
          shortPaymentHandling: shortPaymentHandling,
          shortfallAmount: shortfallAmount != null && shortfallAmount > 0
              ? shortfallAmount.toStringAsFixed(4)
              : null,
          allocations: allocations,
        ),
      );

      ref.invalidate(paymentInRecordsProvider);
      ref.invalidate(saleInvoicesProvider);
      if (shortPaymentHandling == 'unrecovered' && state.partyId != null) {
        ref.invalidate(partyHiddenLedgerSummaryProvider(state.partyId!));
        ref.invalidate(partyHiddenLedgerEntriesProvider(state.partyId!));
      }
      refreshAfterPaymentIn(
        ref,
        context: (partyId: payment.partyId, itemIds: const []),
      );
      if (payment.discount > 0) {
        refreshAfterExpense(
          ref,
          context: (partyId: payment.partyId, itemIds: const []),
        );
      }
      final paymentId = created.id;
      final synced = await syncTransactionAttachments(
        ref,
        entityType: DocumentAttachmentEntityType.paymentIn.apiValue,
        entityId: paymentId,
        images: state.attachedImages,
        documents: state.attachedDocuments,
      );
      if (synced != null) {
        state = state.copyWith(
          attachedImages: synced.images,
          attachedDocuments: synced.documents,
        );
      }
      reset();
      // Fire-and-forget WhatsApp notify when local settings allow.
      // ignore: unawaited_futures
      WhatsAppAutoNotify.afterPaymentIn(ref, paymentId: paymentId);
      return (error: null, paymentId: paymentId);
    } catch (error) {
      final message = SalesErrorMapper.messageFor(error);
      state = state.copyWith(isSaving: false, saveError: message);
      return (error: message, paymentId: null);
    }
  }
}
