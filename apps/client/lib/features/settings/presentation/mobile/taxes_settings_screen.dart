import 'package:billing_baba/features/settings/presentation/mobile/widgets/mobile_settings_placeholder_body.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_settings_detail_page.dart';
import 'package:flutter/material.dart';

class MobileTaxesSettingsScreen extends StatelessWidget {
  const MobileTaxesSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MobileSettingsDetailPage(
      title: 'Taxes',
      subtitle: 'GST and tax configuration',
      body: MobileSettingsPlaceholderBody(
        title: 'Taxes',
        message: 'GST slabs and tax preferences will be configurable here.',
      ),
    );
  }
}
