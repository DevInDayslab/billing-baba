import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/add_expense_page.dart';
import './mobile/add_expense_page.dart';
import 'package:flutter/widgets.dart';

class AddExpensePage extends StatelessWidget {
  const AddExpensePage({
    super.key,
    this.expenseId,
  });

  final String? expenseId;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: DesktopAddExpensePage(expenseId: expenseId),
      mobile: MobileAddExpensePage(expenseId: expenseId),
    );
  }
}
