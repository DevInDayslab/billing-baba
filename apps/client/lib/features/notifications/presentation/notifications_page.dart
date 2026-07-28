import 'package:billing_baba/core/widgets/adaptive_page.dart';
import 'package:billing_baba/features/dashboard/presentation/coming_soon_page.dart';
import 'package:billing_baba/features/notifications/presentation/mobile/notifications_page.dart';
import 'package:flutter/widgets.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: ComingSoonPage(title: 'Notifications'),
      mobile: MobileNotificationsPage(),
    );
  }
}
