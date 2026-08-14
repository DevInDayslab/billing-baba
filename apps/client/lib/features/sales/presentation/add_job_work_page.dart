import 'package:billing_baba/features/sales/presentation/desktop/job_work_out_page.dart';
import 'package:billing_baba/features/sales/presentation/mobile/add_job_work_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class AddJobWorkPage extends StatelessWidget {
  const AddJobWorkPage({super.key, this.orderId});

  final String? orderId;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopJobWorkOutPage(),
      mobile: MobileAddJobWorkPage(orderId: orderId),
    );
  }
}
