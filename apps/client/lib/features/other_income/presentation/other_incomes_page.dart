import 'package:billing_baba/features/other_income/presentation/desktop/other_incomes_page.dart';
import 'package:billing_baba/features/other_income/presentation/mobile/other_incomes_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/widgets.dart';

class OtherIncomesPage extends StatelessWidget {
  const OtherIncomesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopOtherIncomesPage(),
      mobile: MobileOtherIncomesPage(),
    );
  }
}
