import 'package:flutter/material.dart';

enum MobileHomeView { transactionDetails, partyDetails }

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
  estimate('Estimate');

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
}

enum MobileHomeTransactionStatusType {
  payinUnused,
  salePaid,
  estimateOpen,
}

extension MobileHomeTransactionStatusTypeX on MobileHomeTransactionStatusType {
  Color get backgroundColor => switch (this) {
    MobileHomeTransactionStatusType.payinUnused => const Color(0xFFFFF8E1),
    MobileHomeTransactionStatusType.salePaid => const Color(0xFFE8F5E9),
    MobileHomeTransactionStatusType.estimateOpen => const Color(0xFFFFF3E0),
  };

  Color get textColor => switch (this) {
    MobileHomeTransactionStatusType.payinUnused => const Color(0xFFF9A825),
    MobileHomeTransactionStatusType.salePaid => const Color(0xFF2E7D32),
    MobileHomeTransactionStatusType.estimateOpen => const Color(0xFFEF6C00),
  };
}

class MobileHomeQuickLink {
  const MobileHomeQuickLink({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    this.iconColor = Colors.white,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onTap;
}
