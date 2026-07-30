import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_scoped_transaction_page.dart';
import 'package:flutter/material.dart';

class MobilePurchaseOrderPage extends StatelessWidget {
  const MobilePurchaseOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MobileScopedTransactionPage(route: AppRoutes.purchaseOrder);
  }
}
