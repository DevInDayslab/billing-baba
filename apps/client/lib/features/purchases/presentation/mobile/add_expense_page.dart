import 'package:flutter/material.dart';

class MobileAddExpensePage extends StatelessWidget {
  const MobileAddExpensePage({
    super.key,
    this.expenseId,
  });

  final String? expenseId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Add Expense — Mobile UI coming soon'),
      ),
    );
  }
}
