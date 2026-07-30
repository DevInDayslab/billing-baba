import 'package:flutter/material.dart';

class MobileAddDeliveryChallanPage extends StatelessWidget {
  const MobileAddDeliveryChallanPage({
    super.key,
    this.challanId,
    this.duplicateFromId,
  });

  final String? challanId;
  final String? duplicateFromId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Add Delivery Challan — Mobile UI coming soon'),
      ),
    );
  }
}
