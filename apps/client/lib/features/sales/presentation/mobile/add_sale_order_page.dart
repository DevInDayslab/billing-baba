import 'package:flutter/material.dart';

class MobileAddSaleOrderPage extends StatelessWidget {
  const MobileAddSaleOrderPage({
    super.key,
    this.orderId,
  });

  final String? orderId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Add Sale Order — Mobile UI coming soon'),
      ),
    );
  }
}
