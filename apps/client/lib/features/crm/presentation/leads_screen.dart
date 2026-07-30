import 'package:billing_baba/features/crm/presentation/desktop/leads_screen.dart';
import 'package:billing_baba/features/crm/presentation/mobile/leads_screen.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class LeadsScreen extends StatelessWidget {
  const LeadsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopLeadsScreen(),
      mobile: MobileLeadsScreen(),
    );
  }
}
