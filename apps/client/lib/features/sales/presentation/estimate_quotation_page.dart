import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/estimate_quotation_page.dart';
import './mobile/estimate_quotation_page.dart';
import 'package:flutter/widgets.dart';

class EstimateQuotationPage extends StatelessWidget {
  const EstimateQuotationPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopEstimateQuotationPage(),
      mobile: const MobileEstimateQuotationPage(),
    );
  }
}
