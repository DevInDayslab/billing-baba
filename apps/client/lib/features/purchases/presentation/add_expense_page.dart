import 'package:billing_baba/features/purchases/presentation/desktop/add_expense_page.dart';
import 'package:billing_baba/features/purchases/presentation/mobile/add_expense_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
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
