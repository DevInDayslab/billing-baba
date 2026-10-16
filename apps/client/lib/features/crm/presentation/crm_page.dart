import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/features/crm/presentation/desktop/desktop_crm_page.dart';
import 'package:billing_baba/features/crm/presentation/mobile/contacts_screen.dart';
import 'package:billing_baba/features/crm/presentation/mobile/deals_screen.dart';
import 'package:billing_baba/features/crm/presentation/mobile/leads_screen.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CrmPage extends StatelessWidget {
  const CrmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopCrmPage(),
      mobile: Builder(
        builder: (context) {
          final location = GoRouterState.of(context).uri.path;
          if (location.startsWith(AppRoutes.crmContacts)) {
            return const MobileContactsScreen();
          }
          if (location.startsWith(AppRoutes.crmDeals)) {
            return const MobileDealsScreen();
          }
          return const MobileLeadsScreen();
        },
      ),
    );
  }
}
