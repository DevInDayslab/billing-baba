import 'package:billing_baba/core/widgets/adaptive_page.dart';
import 'package:billing_baba/features/collaboration/presentation/desktop/access_denied_page.dart';
import 'package:billing_baba/features/collaboration/presentation/mobile/access_denied_page.dart';
import 'package:flutter/widgets.dart';

class AccessDeniedPage extends StatelessWidget {
  const AccessDeniedPage({
    super.key,
    this.fromRoute,
  });

  final String? fromRoute;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: DesktopAccessDeniedPage(fromRoute: fromRoute),
      mobile: MobileAccessDeniedPage(fromRoute: fromRoute),
    );
  }
}
