import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/reports_page.dart';
import './mobile/reports_page.dart';
import 'package:flutter/widgets.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopReportsPage(),
      mobile: const MobileReportsPage(),
    );
  }
}
