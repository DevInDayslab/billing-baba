import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/hidden_ledger/presentation/hidden_ledger_list_page.dart';
import 'package:billing_baba/features/parties/presentation/desktop/parties_page.dart';
import 'package:billing_baba/features/parties/presentation/mobile/party_details_page.dart';
import 'package:billing_baba/features/parties/presentation/mobile/party_groups_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PartiesPage extends StatelessWidget {
  const PartiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopPartiesPage(),
      mobile: Builder(
        builder: (context) {
          final location = GoRouterState.of(context).uri.path;
          if (location.startsWith(AppRoutes.partyGroups)) {
            return const MobilePartyGroupsPage();
          }
          if (location.startsWith(AppRoutes.partyHiddenLedger)) {
            return const HiddenLedgerListPage();
          }
          return const MobilePartyDetailsPage();
        },
      ),
    );
  }
}
