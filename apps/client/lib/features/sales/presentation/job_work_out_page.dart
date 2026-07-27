import 'package:billing_baba/features/sales/presentation/desktop/job_work_out_page.dart';
import 'package:billing_baba/features/sales/presentation/mobile/job_work_out_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class JobWorkOutPage extends StatelessWidget {
  const JobWorkOutPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopJobWorkOutPage(),
      mobile: MobileJobWorkOutPage(),
    );
  }
}
