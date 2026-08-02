import 'package:billing_baba/features/sales/presentation/desktop/add_estimate_page.dart';
import 'package:billing_baba/features/sales/presentation/mobile/add_estimate_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class AddEstimatePage extends StatelessWidget {
  const AddEstimatePage({
    super.key,
    this.estimateId,
    this.duplicateFromId,
  });

  final String? estimateId;
  final String? duplicateFromId;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: DesktopAddEstimatePage(
        estimateId: estimateId,
        duplicateFromId: duplicateFromId,
      ),
      mobile: MobileAddEstimatePage(
        estimateId: estimateId,
        duplicateFromId: duplicateFromId,
      ),
    );
  }
}
