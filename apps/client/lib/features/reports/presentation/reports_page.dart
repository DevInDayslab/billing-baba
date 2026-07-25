import 'package:billing_baba/core/widgets/adaptive_page.dart';
import 'package:billing_baba/features/reports/presentation/desktop/reports_page.dart';
import 'package:billing_baba/features/reports/presentation/mobile/reports_page.dart';
import 'package:flutter/widgets.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopReportsPage(),
      mobile: MobileReportsPage(),
    );
  }
}
