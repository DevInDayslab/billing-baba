import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:billing_baba/features/purchases/application/purchase_list_filter_utils.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_column_date_filter.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_column_select_filter.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_column_text_filter.dart';

enum PartyTransactionStatus { paid, unpaid, partial }

abstract final class PartyLedgerTransactionMetrics {
  static double totalAmount(PartyLedgerTransactionModel tx) {
    return tx.debit > 0 ? tx.debit : tx.credit;
  }

  static double? balanceUnused(
    PartyLedgerTransactionModel tx,
    PartyTransactionStatus status,
  ) {
    if (tx.entryType == 'payment') return null;
    final total = totalAmount(tx);
    if (status == PartyTransactionStatus.paid) return total;
    if (status == PartyTransactionStatus.partial) return total - tx.credit;
    return total;
  }

  static PartyTransactionStatus statusFor(PartyLedgerTransactionModel tx) {
    if (tx.entryType == 'payment') return PartyTransactionStatus.paid;
    if (tx.credit > 0 && tx.debit > 0) return PartyTransactionStatus.partial;
    if (tx.credit > 0) return PartyTransactionStatus.paid;
    return PartyTransactionStatus.unpaid;
  }
}

class PartyLedgerColumnFilters {
  const PartyLedgerColumnFilters({
    this.typeFilter,
    this.numberFilter,
    this.dateFilter,
    this.totalFilter,
    this.balanceFilter,
    this.dueDateFilter,
    this.statusFilter = allStatusLabel,
  });

  static const allStatusLabel = 'All Status';

  final SelectColumnFilter? typeFilter;
  final TextColumnFilter? numberFilter;
  final DateColumnFilter? dateFilter;
  final PurchaseNumericFilter? totalFilter;
  final PurchaseNumericFilter? balanceFilter;
  final DateColumnFilter? dueDateFilter;
  final String statusFilter;

  bool get hasColumnFilters =>
      typeFilter != null ||
      numberFilter != null ||
      dateFilter != null ||
      totalFilter != null ||
      balanceFilter != null ||
      dueDateFilter != null ||
      statusFilter != allStatusLabel;

  PartyLedgerColumnFilters copyWith({
    SelectColumnFilter? typeFilter,
    bool clearTypeFilter = false,
    TextColumnFilter? numberFilter,
    bool clearNumberFilter = false,
    DateColumnFilter? dateFilter,
    bool clearDateFilter = false,
    PurchaseNumericFilter? totalFilter,
    bool clearTotalFilter = false,
    PurchaseNumericFilter? balanceFilter,
    bool clearBalanceFilter = false,
    DateColumnFilter? dueDateFilter,
    bool clearDueDateFilter = false,
    String? statusFilter,
  }) {
    return PartyLedgerColumnFilters(
      typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
      numberFilter:
          clearNumberFilter ? null : (numberFilter ?? this.numberFilter),
      dateFilter: clearDateFilter ? null : (dateFilter ?? this.dateFilter),
      totalFilter: clearTotalFilter ? null : (totalFilter ?? this.totalFilter),
      balanceFilter:
          clearBalanceFilter ? null : (balanceFilter ?? this.balanceFilter),
      dueDateFilter:
          clearDueDateFilter ? null : (dueDateFilter ?? this.dueDateFilter),
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }

  bool matches(PartyLedgerTransactionModel transaction) {
    if (typeFilter != null && !typeFilter!.matches(transaction.type)) {
      return false;
    }

    final refNo = transaction.referenceNumber?.trim() ?? '';
    if (numberFilter != null && !numberFilter!.matches(refNo)) {
      return false;
    }

    if (dateFilter != null && !dateFilter!.matches(transaction.date)) {
      return false;
    }

    final total = PartyLedgerTransactionMetrics.totalAmount(transaction);
    if (totalFilter != null && !totalFilter!.matches(total)) {
      return false;
    }

    final status = PartyLedgerTransactionMetrics.statusFor(transaction);
    final balance = PartyLedgerTransactionMetrics.balanceUnused(
      transaction,
      status,
    );
    if (balanceFilter != null) {
      if (balance == null) return false;
      if (!balanceFilter!.matches(balance)) return false;
    }

    if (statusFilter != allStatusLabel) {
      final statusLabel = switch (status) {
        PartyTransactionStatus.paid => 'Paid',
        PartyTransactionStatus.unpaid => 'Unpaid',
        PartyTransactionStatus.partial => 'Partial',
      };
      if (statusLabel != statusFilter) return false;
    }

    return true;
  }
}
