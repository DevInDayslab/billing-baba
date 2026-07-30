import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_settings_detail_page.dart';
import 'package:flutter/material.dart';

class MobileComingSoonPage extends StatelessWidget {
  const MobileComingSoonPage({
    required this.title, super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return MobileSettingsDetailPage(
      title: title,
      body: MobileEmptyState(
        title: '$title coming soon',
        message: 'This feature is under development.',
        icon: Icons.construction_outlined,
      ),
    );
  }
}
