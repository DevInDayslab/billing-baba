import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_scoped_transaction_page.dart';
import 'package:flutter/material.dart';

class MobileSalePlaceholderPage extends StatelessWidget {
  const MobileSalePlaceholderPage({
    required this.title, required this.route, super.key,
  });

  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    return MobileScopedTransactionPage(
      route: route,
      titleOverride: title,
    );
  }
}
