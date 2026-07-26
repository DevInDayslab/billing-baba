import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/expenses_page.dart';
import 'package:billing_baba/features/purchases/presentation/mobile/expenses_page.dart';
import 'package:flutter/widgets.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AdaptivePage(
      desktop: DesktopExpensesPage(),
      mobile: MobileExpensesPage(),
    );
  }
}
