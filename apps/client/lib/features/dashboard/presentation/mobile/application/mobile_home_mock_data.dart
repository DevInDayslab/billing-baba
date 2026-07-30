import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:flutter/material.dart';

/// Demo home transactions matching the Vyapar-style reference UI.
abstract final class MobileHomeMockData {
  // TODO(mobile): Replace with live transaction feed when backend is wired.
  static const transactions = [
    MobileHomeTransactionItem(
      id: 'txn-1',
      partyName: 'naitik123',
      documentNumber: '#1',
      statusLabel: 'PAYIN : UNUSED',
      statusType: MobileHomeTransactionStatusType.payinUnused,
      filterType: MobileHomeTransactionFilterType.paymentIn,
      dateLabel: '27 Mar, 26',
      totalLabel: '₹ 1,000',
      balanceLabel: 'Unused',
      balanceValueLabel: '₹ 1,000',
    ),
    MobileHomeTransactionItem(
      id: 'txn-2',
      partyName: 'NAITIK',
      documentNumber: '#8',
      statusLabel: 'SALE : PAID',
      statusType: MobileHomeTransactionStatusType.salePaid,
      filterType: MobileHomeTransactionFilterType.sale,
      dateLabel: '27 Mar, 26',
      totalLabel: '₹ 1,000',
      balanceLabel: 'Balance',
      balanceValueLabel: '₹ 0',
    ),
    MobileHomeTransactionItem(
      id: 'txn-3',
      partyName: 'NAITIK',
      documentNumber: '#7',
      statusLabel: 'EST : OPEN',
      statusType: MobileHomeTransactionStatusType.estimateOpen,
      filterType: MobileHomeTransactionFilterType.estimate,
      dateLabel: '27 Mar, 26',
      dueDateLabel: 'Due : 27 Mar, 26',
      totalLabel: '₹ 1,000',
      balanceLabel: 'Balance',
      balanceValueLabel: '₹ 0',
    ),
  ];

  static List<MobileHomeQuickLink> quickLinks({
    VoidCallback? onTxnSettings,
    VoidCallback? onAddTxn,
    VoidCallback? onSaleReport,
    VoidCallback? onShowAll,
  }) {
    return [
      MobileHomeQuickLink(
        label: 'Add Txn',
        icon: Icons.add_rounded,
        backgroundColor: const Color(0xFFE3F2FD),
        iconColor: const Color(0xFF42A5F5),
        onTap: onAddTxn,
      ),
      MobileHomeQuickLink(
        label: 'Sale Report',
        icon: Icons.description_outlined,
        backgroundColor: const Color(0xFFE8F5E9),
        iconColor: const Color(0xFF43A047),
        onTap: onSaleReport,
      ),
      MobileHomeQuickLink(
        label: 'Txn Settings',
        icon: Icons.settings_outlined,
        backgroundColor: const Color(0xFFFFF3E0),
        iconColor: const Color(0xFFFF9800),
        onTap: onTxnSettings,
      ),
      MobileHomeQuickLink(
        label: 'Show All',
        icon: Icons.arrow_forward_rounded,
        backgroundColor: const Color(0xFFEDE7F6),
        iconColor: const Color(0xFF5D5FEF),
        onTap: onShowAll,
      ),
    ];
  }

  static List<MobileHomeQuickLink> partyQuickLinks({
    VoidCallback? onNetwork,
    VoidCallback? onPartyStatement,
    VoidCallback? onPartySettings,
    VoidCallback? onShowAll,
  }) {
    return [
      MobileHomeQuickLink(
        label: 'Network',
        icon: Icons.hub_outlined,
        backgroundColor: const Color(0xFFE3F2FD),
        iconColor: const Color(0xFF42A5F5),
        onTap: onNetwork,
      ),
      MobileHomeQuickLink(
        label: 'Party Statement',
        icon: Icons.description_outlined,
        backgroundColor: const Color(0xFFE8F5E9),
        iconColor: const Color(0xFF43A047),
        onTap: onPartyStatement,
      ),
      MobileHomeQuickLink(
        label: 'Party Settings',
        icon: Icons.settings_outlined,
        backgroundColor: const Color(0xFFFFF3E0),
        iconColor: const Color(0xFFFF9800),
        onTap: onPartySettings,
      ),
      MobileHomeQuickLink(
        label: 'Show All',
        icon: Icons.arrow_forward_rounded,
        backgroundColor: const Color(0xFFEDE7F6),
        iconColor: const Color(0xFF5D5FEF),
        onTap: onShowAll,
      ),
    ];
  }
}
