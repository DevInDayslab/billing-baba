import 'package:billing_baba/features/settings/presentation/desktop/desktop_transaction_settings_screen.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/material.dart';

class TransactionSettingsScreen extends StatelessWidget {
  const TransactionSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopTransactionSettingsScreen(),
      mobile: DesktopTransactionSettingsScreen(),
    );
  }
}
