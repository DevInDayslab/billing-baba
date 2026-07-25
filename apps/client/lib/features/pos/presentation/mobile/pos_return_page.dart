import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:flutter/material.dart';

class MobilePosReturnPage extends StatelessWidget {
  const MobilePosReturnPage({
    required this.originalSale, super.key,
  });

  final PosSale originalSale;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Pos Return — Mobile UI coming soon'),
      ),
    );
  }
}
