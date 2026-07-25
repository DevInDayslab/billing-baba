import 'package:billing_baba/features/purchases/models/purchase_order_model.dart';
import 'package:flutter/material.dart';

class PurchaseOrderStatusBadge extends StatelessWidget {
  const PurchaseOrderStatusBadge({required this.status, super.key});

  final PurchaseOrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, backgroundColor, textColor) = switch (status) {
      PurchaseOrderStatus.open => (
        'Open',
        const Color(0xFFE3F2FD),
        const Color(0xFF1565C0),
      ),
      PurchaseOrderStatus.orderCompleted => (
        'Order Completed',
        const Color(0xFFE8F5E9),
        const Color(0xFF2E7D32),
      ),
      PurchaseOrderStatus.partiallyReceived => (
        'Partially Received',
        const Color(0xFFFFF3E0),
        const Color(0xFFE65100),
      ),
      PurchaseOrderStatus.cancelled => (
        'Cancelled',
        const Color(0xFFF5F5F5),
        const Color(0xFF9E9E9E),
      ),
    };

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
