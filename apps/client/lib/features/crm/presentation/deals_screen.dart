import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/deals_screen.dart';
import './mobile/deals_screen.dart';
import 'package:flutter/widgets.dart';

class DealsScreen extends StatelessWidget {
  const DealsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopDealsScreen(),
      mobile: const MobileDealsScreen(),
    );
  }
}
