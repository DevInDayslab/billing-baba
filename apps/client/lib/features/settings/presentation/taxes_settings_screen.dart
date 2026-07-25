import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/taxes_settings_screen.dart';
import './mobile/taxes_settings_screen.dart';
import 'package:flutter/widgets.dart';

class TaxesSettingsScreen extends StatelessWidget {
  const TaxesSettingsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopTaxesSettingsScreen(),
      mobile: const MobileTaxesSettingsScreen(),
    );
  }
}
