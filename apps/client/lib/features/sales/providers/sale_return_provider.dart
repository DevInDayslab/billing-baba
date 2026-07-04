import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:billing_baba/features/sales/providers/sales_documents_list_provider.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sale_return_provider.g.dart';

const saleReturnPageSize = 10;

final SalesDocumentListScope _salesReturnScope = salesReturnListScope();

class SaleReturnFiltersState {
  const SaleReturnFiltersState({
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

  SaleReturnFiltersState copyWith({
    TimeRangeOption? timeRangeOption,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
    String? selectedUser,
    String? selectedGodown,
    String? selectedStatus,
    int? currentPage,
  }) {
    return SaleReturnFiltersState(
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

class SaleReturnRecord {
  const SaleReturnRecord({
    required this.id,
    required this.date,
    required this.invoiceNo,
    required this.partyName,
    required this.transaction,
    required this.paymentType,
    required this.status,
    required this.amount,
    required this.balance,
    required this.isDraft,
  });

  final String id;
  final DateTime date;
  final String invoiceNo;
  final String partyName;
  final String transaction;
  final String paymentType;
  final String status;
  final double amount;
  final double balance;
  final bool isDraft;
}

class PaginatedSaleReturns {
  const PaginatedSaleReturns({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    this.isLoading = false,
    this.error,
  });

  final List<SaleReturnRecord> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool isLoading;
  final Object? error;
}

String _statusLabel(SaleInvoiceModel invoice) {
  if (invoice.documentStatus == SalesDocumentStatus.cancelled) {
    return 'Cancelled';
  }
  if (invoice.isDraft) return 'Draft';
  return switch (invoice.status) {
    SaleInvoiceStatus.paid => 'Paid',
    SaleInvoiceStatus.unpaid => 'Unpaid',
    SaleInvoiceStatus.partiallyPaid => 'Partial',
    SaleInvoiceStatus.overdue => 'Overdue',
    SaleInvoiceStatus.cancelled => 'Cancelled',
  };
}

SaleReturnRecord _toSaleReturnRecord(SaleInvoiceModel invoice) {
  return SaleReturnRecord(
    id: invoice.id,
    date: invoice.date,
    invoiceNo: invoice.invoiceNo,
    partyName: invoice.partyName,
    transaction: invoice.transactionType,
    paymentType: invoice.paymentType,
    status: _statusLabel(invoice),
    amount: invoice.amount,
    balance: invoice.balance,
    isDraft: invoice.isDraft,
  );
}

@riverpod
class SaleReturnFilters extends _$SaleReturnFilters {
  @override
  SaleReturnFiltersState build() => const SaleReturnFiltersState();

  void setTimeRange(String label) {
    ref.read(salesDocumentFiltersProvider(_salesReturnScope).notifier).setTimeRange(
      label,
    );
    state = state.copyWith(
      timeRangeOption: TimeRangeOptionX.fromLabel(label),
      currentPage: 1,
    );
  }

  void setCustomDateRange(
    DateTimeRange range, {
    bool autoSwitchToCustom = false,
  }) {
    ref
        .read(salesDocumentFiltersProvider(_salesReturnScope).notifier)
        .setCustomDateRange(range, autoSwitchToCustom: autoSwitchToCustom);
    state = state.copyWith(
      customDateRange: range,
      timeRangeOption: autoSwitchToCustom
          ? TimeRangeOption.custom
          : state.timeRangeOption,
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
    ref
        .read(salesDocumentFiltersProvider(_salesReturnScope).notifier)
        .setStatus(status);
    state = state.copyWith(selectedStatus: status, currentPage: 1);
  }

  void setPage(int page) {
    ref.read(salesDocumentFiltersProvider(_salesReturnScope).notifier).setPage(
      page,
    );
    state = state.copyWith(currentPage: page);
  }
}

@riverpod
PaginatedSaleReturns paginatedSaleReturns(Ref ref) {
  final filters = ref.watch(saleReturnFiltersProvider);
  final documentsAsync = ref.watch(salesDocumentsListProvider(_salesReturnScope));

  return documentsAsync.when(
    loading: () => const PaginatedSaleReturns(
      items: [],
      currentPage: 1,
      totalPages: 1,
      totalItems: 0,
      isLoading: true,
    ),
    error: (error, _) => PaginatedSaleReturns(
      items: const [],
      currentPage: 1,
      totalPages: 1,
      totalItems: 0,
      error: error,
    ),
    data: (page) {
      var items = page.items.map(_toSaleReturnRecord).toList();

      if (filters.selectedGodown != 'All Godown') {
        items = items
            .where(
              (record) => page.items
                  .firstWhere((invoice) => invoice.id == record.id)
                  .godown ==
                  filters.selectedGodown,
            )
            .toList();
      }

      return PaginatedSaleReturns(
        items: items,
        currentPage: page.currentPage,
        totalPages: page.totalPages,
        totalItems: page.totalItems,
      );
    },
  );
}

@riverpod
Future<void> saleReturnRefresh(Ref ref) async {
  await ref.read(salesDocumentsListProvider(_salesReturnScope).notifier).refresh();
}

@riverpod
Future<String?> deleteSaleReturnDraft(Ref ref, String documentId) {
  return ref
      .read(salesDocumentsListProvider(_salesReturnScope).notifier)
      .deleteDraft(documentId);
}

@riverpod
Future<String?> finalizeSaleReturn(Ref ref, String documentId) {
  return ref
      .read(salesDocumentsListProvider(_salesReturnScope).notifier)
      .finalizeDocument(documentId);
}
