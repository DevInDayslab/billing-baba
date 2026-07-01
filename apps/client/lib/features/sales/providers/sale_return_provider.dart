import 'package:billing_baba/features/sales/providers/credit_note_form_provider.dart';
import 'package:billing_baba/features/sales/providers/sale_invoices_provider.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sale_return_provider.g.dart';

const saleReturnPageSize = 10;

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
    required this.date,
    required this.invoiceNo,
    required this.partyName,
    required this.transaction,
    required this.paymentType,
    required this.status,
    required this.amount,
    required this.balance,
  });

  final DateTime date;
  final String invoiceNo;
  final String partyName;
  final String transaction;
  final String paymentType;
  final String status;
  final double amount;
  final double balance;
}

class PaginatedSaleReturns {
  const PaginatedSaleReturns({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  final List<SaleReturnRecord> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
}

@riverpod
class SaleReturnFilters extends _$SaleReturnFilters {
  @override
  SaleReturnFiltersState build() => const SaleReturnFiltersState();

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
    state = state.copyWith(selectedStatus: status, currentPage: 1);
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }
}

@riverpod
PaginatedSaleReturns paginatedSaleReturns(Ref ref) {
  final filters = ref.watch(saleReturnFiltersProvider);
  final savedNotes = ref.watch(savedCreditNotesProvider);
  final allItems = savedNotes
      .map(
        (note) => SaleReturnRecord(
          date: note.returnDate ?? note.savedAt,
          invoiceNo: note.returnNo,
          partyName: note.party,
          transaction: 'Sale Return',
          paymentType: note.paymentType,
          status: 'Paid',
          amount: note.total,
          balance: 0,
        ),
      )
      .toList();

  final totalItems = allItems.length;
  final totalPages = totalItems == 0
      ? 1
      : (totalItems / saleReturnPageSize).ceil();
  final page = filters.currentPage.clamp(1, totalPages);
  final start = (page - 1) * saleReturnPageSize;

  return PaginatedSaleReturns(
    items: allItems.skip(start).take(saleReturnPageSize).toList(),
    currentPage: page,
    totalPages: totalPages,
    totalItems: totalItems,
  );
}
