import 'package:billing_baba/features/sales/application/sale_orders_provider.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:flutter/material.dart';

class SaleOrderStatusBadge extends StatelessWidget {
  const SaleOrderStatusBadge({
    required this.order,
    this.plain = false,
    super.key,
  });

  final SaleInvoiceModel order;
  final bool plain;

  @override
  Widget build(BuildContext context) {
    final displayStatus = saleOrderDisplayStatus(order);
    final (label, backgroundColor, textColor) = switch (displayStatus) {
      SaleOrderDisplayStatus.overdue => (
        'Order Overdue',
        const Color(0xFFFFF3E0),
        const Color(0xFFE65100),
      ),
      SaleOrderDisplayStatus.completed => (
        'Order Completed',
        const Color(0xFFE8F5E9),
        const Color(0xFF2E7D32),
      ),
      SaleOrderDisplayStatus.open => (
        'Open',
        const Color(0xFFE3F2FD),
        const Color(0xFF1565C0),
      ),
      SaleOrderDisplayStatus.draft => (
        'Draft',
        const Color(0xFFFFF3E0),
        const Color(0xFFE65100),
      ),
      SaleOrderDisplayStatus.cancelled => (
        'Cancelled',
        const Color(0xFFF5F5F5),
        const Color(0xFF9E9E9E),
      ),
    };

    if (plain) {
      return Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
