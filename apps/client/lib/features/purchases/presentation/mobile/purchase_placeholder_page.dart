import 'package:billing_baba/core/widgets/mobile/transaction/mobile_scoped_transaction_page.dart';
import 'package:flutter/material.dart';

class MobilePurchasePlaceholderPage extends StatelessWidget {
  const MobilePurchasePlaceholderPage({
    super.key,
    required this.title,
    required this.route,
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
