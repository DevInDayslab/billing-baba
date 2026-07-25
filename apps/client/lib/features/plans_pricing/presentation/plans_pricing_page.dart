import 'package:billing_baba/core/widgets/adaptive_page.dart';
import 'package:billing_baba/features/plans_pricing/presentation/desktop/plans_pricing_page.dart';
import 'package:billing_baba/features/plans_pricing/presentation/mobile/plans_pricing_page.dart';
import 'package:flutter/widgets.dart';

class PlansPricingPage extends StatelessWidget {
  const PlansPricingPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopPlansPricingPage(),
      mobile: MobilePlansPricingPage(),
    );
  }
}
