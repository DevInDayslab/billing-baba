import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/plans_pricing_page.dart';
import './mobile/plans_pricing_page.dart';
import 'package:flutter/widgets.dart';

class PlansPricingPage extends StatelessWidget {
  const PlansPricingPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopPlansPricingPage(),
      mobile: const MobilePlansPricingPage(),
    );
  }
}
