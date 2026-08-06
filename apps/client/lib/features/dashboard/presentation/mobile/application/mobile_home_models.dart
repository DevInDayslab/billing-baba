import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:flutter/material.dart';

enum MobileHomeView { businessOverview, transactionDetails, alerts }

/// Transaction document types for the mobile home filter sheet.
enum MobileHomeTransactionFilterType {
  sale('Sale'),
  saleOrder('Sale Order'),
  creditNote('Credit Note'),
  purchase('Purchase'),
  purchaseOrder('Purchase Order'),
  debitNote('Debit Note'),
  paymentIn('Payment-In'),
  paymentOut('Payment-Out'),
  estimate('Estimate'),
  expense('Expense');

  const MobileHomeTransactionFilterType(this.label);

  final String label;
}

/// A transaction row shown on the mobile home screen.
class MobileHomeTransactionItem {
  const MobileHomeTransactionItem({
    required this.id,
    required this.partyName,
    required this.documentNumber,
    required this.statusLabel,
    required this.statusType,
    required this.filterType,
    required this.dateLabel,
    required this.totalLabel,
    required this.balanceLabel,
    required this.balanceValueLabel,
    this.dueDateLabel,
    this.paymentMethod,
    this.title,
    this.timeLabel,
    this.transactionDate,
    this.ledgerTransaction,
  });

  final String id;
  final String partyName;
  final String documentNumber;
  final String statusLabel;
  final MobileHomeTransactionStatusType statusType;
  final MobileHomeTransactionFilterType filterType;
  final String dateLabel;
  final String totalLabel;
  final String balanceLabel;
  final String balanceValueLabel;
  final String? dueDateLabel;
  final String? paymentMethod;
  final String? title;
  final String? timeLabel;
  final DateTime? transactionDate;

  /// Ledger model for print/share/more actions via desktop handlers.
  final PartyLedgerTransactionModel? ledgerTransaction;
}

enum MobileHomeTransactionStatusType {
  payinUnused,
  salePaid,
  estimateOpen,
  purchase,
  paymentIn,
  paymentOut,
  expense,
}

extension MobileHomeTransactionStatusTypeX on MobileHomeTransactionStatusType {
  ColorPair get colors => switch (this) {
    MobileHomeTransactionStatusType.payinUnused => (
      bg: const Color(0xFFFFF8E1),
      fg: const Color(0xFFF9A825),
    ),
    MobileHomeTransactionStatusType.salePaid => (
      bg: const Color(0xFFE8F5E9),
      fg: const Color(0xFF2E7D32),
    ),
    MobileHomeTransactionStatusType.estimateOpen => (
      bg: const Color(0xFFFFF3E0),
      fg: const Color(0xFFEF6C00),
    ),
    MobileHomeTransactionStatusType.purchase => (
      bg: const Color(0xFFE3F2FD),
      fg: const Color(0xFF1976D2),
    ),
    MobileHomeTransactionStatusType.paymentIn => (
      bg: const Color(0xFFE8F5E9),
      fg: const Color(0xFF2E7D32),
    ),
    MobileHomeTransactionStatusType.paymentOut => (
      bg: const Color(0xFFFFEBEE),
      fg: const Color(0xFFC62828),
    ),
    MobileHomeTransactionStatusType.expense => (
      bg: const Color(0xFFFFF3E0),
      fg: const Color(0xFFEF6C00),
    ),
  };
}

typedef ColorPair = ({Color bg, Color fg});

class MobileHomeQuickLink {
  const MobileHomeQuickLink({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    this.iconColor = const Color(0xFFFFFFFF),
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onTap;
}
