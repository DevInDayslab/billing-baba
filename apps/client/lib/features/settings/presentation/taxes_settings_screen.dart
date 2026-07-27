import 'package:billing_baba/features/settings/presentation/desktop/taxes_settings_screen.dart';
import 'package:billing_baba/features/settings/presentation/mobile/taxes_settings_screen.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class TaxesSettingsScreen extends StatelessWidget {
  const TaxesSettingsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopTaxesSettingsScreen(),
      mobile: MobileTaxesSettingsScreen(),
    );
  }
}
