import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/export/utils/paginated_fetch.dart';
import 'package:billing_baba/features/purchases/application/purchase_bills_provider.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/application/purchase_list_filter_utils.dart';
import 'package:billing_baba/features/purchases/application/purchase_service.dart';
import 'package:billing_baba/features/purchases/models/payment_out_model.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/shared/purchase_shared_column_filters.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:billing_baba/features/sales/application/sale_invoices_provider.dart';
import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:billing_baba/shared/attachments/document_attachment_entity_type.dart';
import 'package:billing_baba/shared/attachments/transaction_attachment_actions.dart';
import 'package:billing_baba/shared/forms/transaction_form_validation.dart';
import 'package:billing_baba/shared/forms/transaction_party_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_out_provider.g.dart';

const paymentOutPageSize = 10;

/// One-shot success message shown on the payment out list after save.
final paymentOutSaveSuccessMessageProvider =
    NotifierProvider<PaymentOutSaveSuccessMessage, String?>(
      PaymentOutSaveSuccessMessage.new,
    );

class PaymentOutSaveSuccessMessage extends Notifier<String?> {
  @override
  String? build() => null;

  void setMessage(String? value) => state = value;
}

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
    this.selectedStatus = 'All Status',
    this.currentPage = 1,
    this.columnFilters = const PurchaseColumnFilterFields(),
  });

  final TimeRangeOption timeRangeOption;
  final DateTimeRange? customDateRange;
  final String selectedFirm;
  final String selectedUser;
  final String selectedStatus;
  final int currentPage;
  final PurchaseColumnFilterFields columnFilters;

  String get timeRangeLabel => timeRangeOption.label;

  bool get hasActiveFilters =>
      timeRangeOption != TimeRangeOption.thisMonth ||
      customDateRange != null ||
      selectedFirm != 'All Firms' ||
      selectedUser != 'All Users' ||
      selectedStatus != 'All Status' ||
      columnFilters.hasColumnFilters;

  PaymentOutFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
    String? selectedFirm,
    String? selectedUser,
    String? selectedStatus,
    int? currentPage,
    PurchaseColumnFilterFields? columnFilters,
  }) {
    return PaymentOutFiltersState(
      timeRangeOption: timeRangeOption ?? this.timeRangeOption,
      customDateRange: clearCustomDateRange
          ? null
          : (customDateRange ?? this.customDateRange),
      selectedFirm: selectedFirm ?? this.selectedFirm,
      selectedUser: selectedUser ?? this.selectedUser,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      currentPage: currentPage ?? this.currentPage,
      columnFilters: columnFilters ?? this.columnFilters,
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

PaymentOutStatus? _paymentOutStatusFromFilterLabel(String label) =>
    switch (label) {
      'Paid' => PaymentOutStatus.paid,
      'Pending' => PaymentOutStatus.pending,
      'Cancelled' => PaymentOutStatus.cancelled,
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

PaymentListQuery _buildPaymentListQuery(PaymentOutFiltersState filters) {
  final dateRange = _resolveTimeRange(
    filters.timeRangeOption,
    filters.customDateRange,
  );

  return PaymentListQuery(
    limit: PaginatedFetch.defaultPageSize,
    direction: 'paid',
    from: dateRange?.start.toUtc().toIso8601String(),
    to: dateRange?.end.toUtc().toIso8601String(),
  );
}

List<PaymentOutModel> _applyFilters(
  List<PaymentOutModel> records,
  PaymentOutFiltersState filters,
  String globalSearch,
) {
  final statusFilter = _paymentOutStatusFromFilterLabel(filters.selectedStatus);
  final columns = filters.columnFilters;
  final globalQuery = globalSearch.trim().toLowerCase();

  return records.where((record) {
    if (globalQuery.isNotEmpty &&
        !purchaseFilterMatchesGlobalSearch(globalQuery, [
          record.receiptNo,
          record.partyName,
          record.paymentType,
        ])) {
      return false;
    }

    if (columns.columnDateRange != null &&
        !purchaseFilterIsWithinDateRange(
          record.date,
          columns.columnDateRange!,
        )) {
      return false;
    }

    if (!purchaseFilterMatchesText(
      columns.documentNoFilter,
      record.receiptNo,
    )) {
      return false;
    }

    if (!purchaseFilterMatchesParty(columns.selectedParty, record.partyName)) {
      return false;
    }

    if (!purchaseFilterMatchesNumericFilter(
      record.totalAmount,
      columns.totalAmountFilter,
    )) {
      return false;
    }

    if (!purchaseFilterMatchesNumericFilter(
      record.paidAmount,
      columns.paidAmountFilter,
    )) {
      return false;
    }

    if (!purchaseFilterMatchesPaymentTypes(
      columns.selectedPaymentTypes,
      record.paymentType,
    )) {
      return false;
    }

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

    return true;
  }).toList();
}

PaginatedPaymentOut _paginateFilteredRecords(
  List<PaymentOutModel> filtered,
  int currentPage,
) {
  final slice = purchaseFilterPaginate(
    filtered,
    currentPage,
    paymentOutPageSize,
  );
  return PaginatedPaymentOut(
    items: slice.items,
    currentPage: slice.currentPage,
    totalPages: slice.totalPages,
    totalItems: slice.totalItems,
  );
}

PaginatedPaymentOut _allRecordsPage(List<PaymentOutModel> allRecords) {
  return PaginatedPaymentOut(
    items: allRecords,
    currentPage: 1,
    totalPages: 1,
    totalItems: allRecords.length,
  );
}

List<PaymentOutModel> _allRecordsFromAsync(
  AsyncValue<PaginatedPaymentOut> recordsAsync,
) {
  return recordsAsync.when(
    data: (page) => page.items,
    loading: () => const [],
    error: (_, _) => const [],
  );
}

@Riverpod(keepAlive: true)
class PaymentOutSearchQuery extends _$PaymentOutSearchQuery {
  @override
  String build() => '';

  void setQuery(String value) {
    state = value;
    final filters = ref.read(paymentOutFiltersProvider);
    if (filters.currentPage != 1) {
      ref.read(paymentOutFiltersProvider.notifier).setPage(1);
    }
  }
}

@Riverpod(keepAlive: true)
class PaymentOutRecords extends _$PaymentOutRecords {
  @override
  Future<PaginatedPaymentOut> build() async {
    ref.watch(
      paymentOutFiltersProvider.select(
        (filters) => (filters.timeRangeOption, filters.customDateRange),
      ),
    );
    final allRecords = await _fetchAllRecords();
    return _allRecordsPage(allRecords);
  }

  Future<List<PaymentOutModel>> _fetchAllRecords() async {
    final filters = ref.read(paymentOutFiltersProvider);
    final service = await ref.read(purchaseServiceProvider.future);

    return PaginatedFetch.fetchAll(
      fetchPage: (page) async {
        final baseQuery = _buildPaymentListQuery(filters);
        final query = PaymentListQuery(
          page: page,
          limit: baseQuery.limit,
          direction: baseQuery.direction,
          from: baseQuery.from,
          to: baseQuery.to,
        );
        final pageResult = await service.fetchPaymentsPage(query);
        return (
          items: pageResult.items,
          totalPages: pageResult.totalPages,
        );
      },
    );
  }

  Future<void> refresh({bool silent = false}) async {
    if (!silent && !state.hasValue) {
      state = const AsyncLoading();
    }
    state = await AsyncValue.guard(() async {
      final allRecords = await _fetchAllRecords();
      return _allRecordsPage(allRecords);
    });
  }

  Future<void> refreshAllRelated({bool silent = false}) async {
    ref.read(paymentOutFiltersProvider.notifier).ensureFirstPage();
    await refresh(silent: silent);
    await ref.read(purchaseBillsProvider.notifier).refresh();
  }

  /// Inserts a freshly saved payment at the top of page 1 until the API refresh
  /// completes, so the list updates immediately after save.
  void optimisticPrepend(PaymentOutModel record) {
    final filters = ref.read(paymentOutFiltersProvider);
    final search = ref.read(paymentOutSearchQueryProvider);
    if (filters.currentPage != 1) return;
    if (_applyFilters([record], filters, search).isEmpty) return;

    final value = state.asData?.value;
    if (value == null) {
      state = AsyncData(
        PaginatedPaymentOut(
          items: [record],
          currentPage: 1,
          totalPages: 1,
          totalItems: 1,
        ),
      );
      return;
    }

    final items = [
      record,
      ...value.items.where((item) => item.id != record.id),
    ].take(PaginatedFetch.defaultPageSize).toList();

    state = AsyncData(
      PaginatedPaymentOut(
        items: items,
        currentPage: value.currentPage,
        totalPages: value.totalPages,
        totalItems: value.totalItems + 1,
      ),
    );
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
  }

  void setUser(String user) {
    state = state.copyWith(selectedUser: user, currentPage: 1);
  }

  void setStatus(String status) {
    state = state.copyWith(selectedStatus: status, currentPage: 1);
  }

  void setColumnDateRange(DateTimeRange range) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(columnDateRange: range),
      currentPage: 1,
    );
  }

  void clearColumnDateRange() {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(clearColumnDateRange: true),
      currentPage: 1,
    );
  }

  void setDocumentNoFilter(String value) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(documentNoFilter: value),
      currentPage: 1,
    );
  }

  void setParty(String party) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(selectedParty: party),
      currentPage: 1,
    );
  }

  void togglePaymentType(String paymentType) {
    final updated = Set<String>.from(state.columnFilters.selectedPaymentTypes);
    if (updated.contains(paymentType)) {
      updated.remove(paymentType);
    } else {
      updated.add(paymentType);
    }
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(
        selectedPaymentTypes: updated,
      ),
      currentPage: 1,
    );
  }

  void clearPaymentTypes() {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(clearPaymentTypes: true),
      currentPage: 1,
    );
  }

  void applyTotalAmountFilter(PurchaseNumericFilter filter) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(totalAmountFilter: filter),
      currentPage: 1,
    );
  }

  void clearTotalAmountFilter() {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(clearTotalAmountFilter: true),
      currentPage: 1,
    );
  }

  void applyPaidAmountFilter(PurchaseNumericFilter filter) {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(paidAmountFilter: filter),
      currentPage: 1,
    );
  }

  void clearPaidAmountFilter() {
    state = state.copyWith(
      columnFilters: state.columnFilters.copyWith(clearPaidAmountFilter: true),
      currentPage: 1,
    );
  }

  void applyAmountFilter(PurchaseNumericFilter filter) {
    applyTotalAmountFilter(filter);
  }

  void clearAmountFilter() {
    clearTotalAmountFilter();
  }

  void applyBalanceFilter(PurchaseNumericFilter filter) {
    applyPaidAmountFilter(filter);
  }

  void clearBalanceFilter() {
    clearPaidAmountFilter();
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void ensureFirstPage() {
    if (state.currentPage != 1) {
      state = state.copyWith(currentPage: 1);
    }
  }

  void clearAllFilters() {
    state = const PaymentOutFiltersState();
    ref.read(paymentOutSearchQueryProvider.notifier).setQuery('');
    ref.invalidate(paymentOutRecordsProvider);
  }
}

@riverpod
List<PaymentOutModel> filteredPaymentOutRecords(Ref ref) {
  final allRecords = _allRecordsFromAsync(ref.watch(paymentOutRecordsProvider));
  final filters = ref.watch(paymentOutFiltersProvider);
  final search = ref.watch(paymentOutSearchQueryProvider);
  return _applyFilters(allRecords, filters, search);
}

@riverpod
PaginatedPaymentOut paginatedPaymentOutRecords(Ref ref) {
  final filtered = ref.watch(filteredPaymentOutRecordsProvider);
  final filters = ref.watch(paymentOutFiltersProvider);
  return _paginateFilteredRecords(filtered, filters.currentPage);
}

@riverpod
List<String> paymentOutPartyOptions(Ref ref) {
  final allRecords = _allRecordsFromAsync(ref.watch(paymentOutRecordsProvider));
  return purchasePartyOptionsFromNames(
    allRecords.map((record) => record.partyName),
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
    this.attachedImages = const [],
    this.attachedDocuments = const [],
    this.showValidationErrors = false,
    this.saveError,
    this.isSaving = false,
    this.isLoadingBalance = false,
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
  final List<SaleFormAttachment> attachedImages;
  final List<SaleFormAttachment> attachedDocuments;
  final bool showValidationErrors;
  final String? saveError;
  final bool isSaving;
  final bool isLoadingBalance;

  double get total =>
      (paidAmount - discount).clamp(0, double.infinity).toDouble();

  bool get isValid =>
      party.trim().isNotEmpty &&
      partyId != null &&
      partyId!.isNotEmpty &&
      total > 0;

  bool get partyHasError => transactionPartyHasError(
    showValidationErrors: showValidationErrors,
    partyId: partyId,
    partyName: party,
  );

  bool get amountHasError => transactionAmountHasError(
    showValidationErrors: showValidationErrors,
    amount: total,
  );

  PaymentOutFormState copyWith({
    String? partyId,
    bool clearPartyId = false,
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
    List<SaleFormAttachment>? attachedImages,
    List<SaleFormAttachment>? attachedDocuments,
    bool? showValidationErrors,
    String? saveError,
    bool clearSaveError = false,
    bool? isSaving,
    bool? isLoadingBalance,
  }) {
    return PaymentOutFormState(
      partyId: clearPartyId ? null : (partyId ?? this.partyId),
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
      attachedImages: attachedImages ?? this.attachedImages,
      attachedDocuments: attachedDocuments ?? this.attachedDocuments,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
      isSaving: isSaving ?? this.isSaving,
      isLoadingBalance: isLoadingBalance ?? this.isLoadingBalance,
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
      balanceDue: clearLink ? 0 : state.balanceDue,
      clearSaveError: true,
      isLoadingBalance: !clearLink && partyId != null && partyId.isNotEmpty,
    );

    final linkedId = state.partyId;
    if (linkedId != null && linkedId.isNotEmpty) {
      try {
        final service = await ref.read(purchaseServiceProvider.future);
        final balanceDue = await service.fetchPartyBalanceDue(linkedId);
        state = state.copyWith(balanceDue: balanceDue, isLoadingBalance: false);
      } catch (_) {
        state = state.copyWith(isLoadingBalance: false);
      }
    }
  }

  String? _validationError() {
    return buildTransactionValidationError(
      hasValidLineItems: true,
      hasValidParty: state.partyId != null && state.partyId!.isNotEmpty,
      hasValidAmount: state.total > 0,
      requireParty: true,
      requireAmount: true,
    );
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

  void addImage(SaleFormAttachment attachment) {
    state = state.copyWith(
      attachedImages: [...state.attachedImages, attachment],
    );
  }

  void removeImage(String id) {
    state = state.copyWith(
      attachedImages: state.attachedImages
          .where((item) => item.id != id)
          .toList(),
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
      attachedDocuments: state.attachedDocuments
          .where((item) => item.id != id)
          .toList(),
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

  Future<({String? error, String? paymentId})> savePayment({
    bool showSuccessMessage = true,
  }) async {
    if (state.isSaving) {
      return (error: null, paymentId: null);
    }

    if (!state.isValid) {
      state = state.copyWith(showValidationErrors: true);
      return (error: _validationError(), paymentId: null);
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

      final paymentAmount = state.total;

      final allocations = await service.buildFifoAllocations(
        partyId: state.partyId!,
        amount: paymentAmount,
      );

      final receiptNo = state.receiptNo;

      final created = await service.createPayment(
        CreatePaymentRequest(
          partyId: state.partyId!,
          direction: 'paid',
          amount: paymentAmount.toStringAsFixed(4),
          paymentMode: PurchasePaymentModes.toApi(state.paymentType),
          paymentDate: paymentDate.toUtc().toIso8601String(),
          referenceNumber: receiptNo,
          notes: state.description.trim().isEmpty ? null : state.description,
          allocations: allocations,
        ),
      );

      ref.read(paymentOutRecordsProvider.notifier).optimisticPrepend(created);
      await ref
          .read(paymentOutRecordsProvider.notifier)
          .refreshAllRelated(silent: true);
      refreshAfterPaymentOut(ref);
      final paymentId = created.id;
      final synced = await syncTransactionAttachments(
        ref,
        entityType: DocumentAttachmentEntityType.paymentOut.apiValue,
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
      state = state.copyWith(isSaving: false);
      reset();
      if (showSuccessMessage) {
        ref
            .read(paymentOutSaveSuccessMessageProvider.notifier)
            .setMessage(
              'Payment $receiptNo saved successfully',
            );
      }
      return (error: null, paymentId: paymentId);
    } catch (error) {
      final message = PurchaseErrorMapper.messageFor(error);
      state = state.copyWith(isSaving: false, saveError: message);
      return (error: message, paymentId: null);
    }
  }
}
