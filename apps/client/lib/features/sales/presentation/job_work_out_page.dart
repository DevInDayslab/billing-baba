import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/job_work_out_page.dart';
import './mobile/job_work_out_page.dart';
import 'package:flutter/widgets.dart';

class JobWorkOutPage extends StatelessWidget {
  const JobWorkOutPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopJobWorkOutPage(),
      mobile: const MobileJobWorkOutPage(),
    );
  }
}
