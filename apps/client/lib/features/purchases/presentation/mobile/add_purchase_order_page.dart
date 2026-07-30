import 'package:flutter/material.dart';

class MobileAddPurchaseOrderPage extends StatelessWidget {
  const MobileAddPurchaseOrderPage({
    super.key,
    this.orderId,
  });

  final String? orderId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Add Purchase Order — Mobile UI coming soon'),
      ),
    );
  }
}
