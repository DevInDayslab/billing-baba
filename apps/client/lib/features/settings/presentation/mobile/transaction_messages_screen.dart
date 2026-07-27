import 'package:billing_baba/features/settings/presentation/mobile/widgets/mobile_settings_placeholder_body.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_settings_detail_page.dart';
import 'package:flutter/material.dart';

class MobileTransactionMessagesScreen extends StatelessWidget {
  const MobileTransactionMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MobileSettingsDetailPage(
      title: 'Transaction Messages',
      subtitle: 'Auto-send templates and message content',
      body: MobileSettingsPlaceholderBody(
        title: 'Transaction Messages',
        message: 'Message templates and auto-send rules will be editable here.',
      ),
    );
  }
}
