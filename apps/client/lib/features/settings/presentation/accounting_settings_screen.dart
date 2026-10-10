import 'package:billing_baba/features/settings/presentation/desktop/desktop_accounting_settings_screen.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/material.dart';

class AccountingSettingsScreen extends StatelessWidget {
  const AccountingSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopAccountingSettingsScreen(),
      mobile: DesktopAccountingSettingsScreen(),
    );
  }
}
