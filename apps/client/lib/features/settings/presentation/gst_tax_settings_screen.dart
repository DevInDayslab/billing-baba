import 'package:billing_baba/features/settings/presentation/desktop/desktop_gst_tax_settings_screen.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/material.dart';

class GstTaxSettingsScreen extends StatelessWidget {
  const GstTaxSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopGstTaxSettingsScreen(),
      mobile: DesktopGstTaxSettingsScreen(),
    );
  }
}
