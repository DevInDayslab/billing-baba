import 'package:billing_baba/features/notifications/presentation/desktop/desktop_notifications_page.dart';
import 'package:billing_baba/features/notifications/presentation/mobile/notifications_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopNotificationsPage(),
      mobile: MobileNotificationsPage(),
    );
  }
}
