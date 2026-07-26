import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/crm/presentation/desktop/deals_screen.dart';
import 'package:billing_baba/features/crm/presentation/mobile/deals_screen.dart';
import 'package:flutter/widgets.dart';

class DealsScreen extends StatelessWidget {
  const DealsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopDealsScreen(),
      mobile: MobileDealsScreen(),
    );
  }
}
