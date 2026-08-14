import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/settings/models/settings_tab.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_menu_grid_sheet.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheet_models.dart';
import 'package:billing_baba/features/reports/models/business_status_report_subsection.dart';
import 'package:billing_baba/features/reports/models/party_report_subsection.dart';
import 'package:billing_baba/features/reports/models/reports_nav_intent.dart';
import 'package:billing_baba/features/reports/models/transaction_report_subsection.dart';
import 'package:flutter/material.dart';

typedef MobileMoreOptionsReportOpener = void Function(ReportsNavIntent intent);

/// Which home tab opened the More Options sheet.
enum MobileMoreOptionsScope { transaction, party }

/// Locks visible sheet height to ~3 grid rows; extra items scroll inside.
const mobileMoreOptionsSheetHeightFraction = 0.50;

const _partyMoreOptionsSheetHeightFraction = 0.38;

/// Vyapar-style "More Options" grid opened from the home Show All quick link.
Future<void> showMobileMoreOptionsSheet({
  required BuildContext context,
  required MobileMoreOptionsScope scope,
  required void Function(String route) onPushRoute,
  required MobileMoreOptionsReportOpener onOpenReport,
  VoidCallback? onImportParty,
  VoidCallback? onInviteParty,
}) {
  final items = switch (scope) {
    MobileMoreOptionsScope.transaction => mobileTransactionMoreOptionsItems(
      onPushRoute: onPushRoute,
      onOpenReport: onOpenReport,
    ),
    MobileMoreOptionsScope.party => mobilePartyMoreOptionsItems(
      onPushRoute: onPushRoute,
      onOpenReport: onOpenReport,
      onImportParty:
          onImportParty ??
          () => _showComingSoonSnackBar(context, 'Import party'),
      onInviteParty:
          onInviteParty ??
          () => _showComingSoonSnackBar(context, 'Invite party'),
    ),
  };

  return showMobileMenuGridSheet(
    context: context,
    title: 'More Options',
    heightFraction: scope == MobileMoreOptionsScope.party
        ? _partyMoreOptionsSheetHeightFraction
        : mobileMoreOptionsSheetHeightFraction,
    items: items,
  );
}

void _showComingSoonSnackBar(BuildContext context, String feature) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$feature coming soon')),
  );
}

List<MobileMenuGridItem> mobileTransactionMoreOptionsItems({
  required void Function(String route) onPushRoute,
  required MobileMoreOptionsReportOpener onOpenReport,
}) {
  void openTransactionReport(TransactionReportSubSection sub) {
    onOpenReport(ReportsNavIntent.transaction(sub));
  }

  return [
    MobileMenuGridItem(
      label: 'Bank Accounts',
      icon: Icons.account_balance_outlined,
      onTap: () => onOpenReport(
        ReportsNavIntent.businessStatus(
          BusinessStatusReportSubSection.bankStatement,
        ),
      ),
    ),
    MobileMenuGridItem(
      label: 'Day Book',
      icon: Icons.menu_book_outlined,
      onTap: () => openTransactionReport(TransactionReportSubSection.dayBook),
    ),
    MobileMenuGridItem(
      label: 'All Txns Report',
      icon: Icons.summarize_outlined,
      onTap: () =>
          openTransactionReport(TransactionReportSubSection.allTransaction),
    ),
    MobileMenuGridItem(
      label: 'Profit & Loss',
      icon: Icons.swap_vert_rounded,
      onTap: () =>
          openTransactionReport(TransactionReportSubSection.profitLoss),
    ),
    MobileMenuGridItem(
      label: 'Balance Sheet',
      icon: Icons.assignment_outlined,
      showPremiumBadge: true,
      onTap: () =>
          openTransactionReport(TransactionReportSubSection.balanceSheet),
    ),
    MobileMenuGridItem(
      label: 'Billwise PnL',
      icon: Icons.bookmark_border_rounded,
      showPremiumBadge: true,
      onTap: () =>
          openTransactionReport(TransactionReportSubSection.billWiseProfit),
    ),
    MobileMenuGridItem(
      label: 'Print Settings',
      icon: Icons.print_outlined,
      onTap: () => onPushRoute(AppRoutes.settingsTab(SettingsTab.print.id)),
    ),
    MobileMenuGridItem(
      label: 'Txn Settings',
      icon: Icons.sms_outlined,
      onTap: () => onPushRoute(
        AppRoutes.settingsTab(SettingsTab.transactionMessages.id),
      ),
    ),
  ];
}

List<MobileMenuGridItem> mobilePartyMoreOptionsItems({
  required void Function(String route) onPushRoute,
  required MobileMoreOptionsReportOpener onOpenReport,
  required VoidCallback onImportParty,
  required VoidCallback onInviteParty,
}) {
  void openPartyReport(PartyReportSubSection sub) {
    onOpenReport(ReportsNavIntent.party(sub));
  }

  return [
    MobileMenuGridItem(
      label: 'Invite Party',
      icon: Icons.share_outlined,
      onTap: onInviteParty,
    ),
    MobileMenuGridItem(
      label: 'Partywise PnL',
      icon: Icons.person_outline_rounded,
      showPremiumBadge: true,
      onTap: () => openPartyReport(PartyReportSubSection.partyWiseProfitLoss),
    ),
    MobileMenuGridItem(
      label: 'All Parties Report',
      icon: Icons.groups_outlined,
      onTap: () => openPartyReport(PartyReportSubSection.allParties),
    ),
    MobileMenuGridItem(
      label: 'Reminder Settings',
      icon: Icons.notifications_active_outlined,
      onTap: () => onPushRoute(AppRoutes.settingsPreferences),
    ),
    MobileMenuGridItem(
      label: 'Import Party',
      icon: Icons.person_add_alt_1_outlined,
      onTap: onImportParty,
    ),
  ];
}
