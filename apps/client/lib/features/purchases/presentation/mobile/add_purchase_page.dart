import 'package:flutter/material.dart';

class MobileAddPurchasePage extends StatelessWidget {
  const MobileAddPurchasePage({
    super.key,
    this.billId,
  });

  final String? billId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Add Purchase — Mobile UI coming soon'),
      ),
    );
  }
}
