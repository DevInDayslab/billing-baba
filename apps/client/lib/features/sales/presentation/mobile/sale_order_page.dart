import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/widgets/mobile/transaction/mobile_scoped_transaction_page.dart';
import 'package:flutter/material.dart';

class MobileSaleOrderPage extends StatelessWidget {
  const MobileSaleOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MobileScopedTransactionPage(route: AppRoutes.saleOrder);
  }
}
