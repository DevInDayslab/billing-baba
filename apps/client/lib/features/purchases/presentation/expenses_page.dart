import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/expenses_page.dart';
import './mobile/expenses_page.dart';
import 'package:flutter/widgets.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: const DesktopExpensesPage(),
      mobile: const MobileExpensesPage(),
    );
  }
}
