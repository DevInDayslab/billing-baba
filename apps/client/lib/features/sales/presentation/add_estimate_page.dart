import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/add_estimate_page.dart';
import './mobile/add_estimate_page.dart';
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
      desktop: DesktopAddEstimatePage(estimateId: estimateId, duplicateFromId: duplicateFromId),
      mobile: MobileAddEstimatePage(estimateId: estimateId, duplicateFromId: duplicateFromId),
    );
  }
}
