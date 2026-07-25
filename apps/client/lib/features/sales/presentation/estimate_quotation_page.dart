import 'package:billing_baba/core/widgets/adaptive_page.dart';
import 'package:billing_baba/features/sales/presentation/desktop/estimate_quotation_page.dart';
import 'package:billing_baba/features/sales/presentation/mobile/estimate_quotation_page.dart';
import 'package:flutter/widgets.dart';

class EstimateQuotationPage extends StatelessWidget {
  const EstimateQuotationPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopEstimateQuotationPage(),
      mobile: MobileEstimateQuotationPage(),
    );
  }
}
