import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/leads_screen.dart';
import './mobile/leads_screen.dart';
import 'package:flutter/widgets.dart';

class LeadsScreen extends StatelessWidget {
  const LeadsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopLeadsScreen(),
      mobile: const MobileLeadsScreen(),
    );
  }
}
