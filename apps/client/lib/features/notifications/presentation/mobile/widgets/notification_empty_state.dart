import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const MobileEmptyState(
      title: "You're all caught up",
      message: 'Notifications will appear here.',
      icon: LucideIcons.bell,
    );
  }
}
