import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:flutter/material.dart';

class SaleInvoiceStatusBadge extends StatelessWidget {
  const SaleInvoiceStatusBadge({
    required this.status,
    this.plain = false,
    super.key,
  });

  final SaleInvoiceStatus status;
  final bool plain;

  @override
  Widget build(BuildContext context) {
    final (label, backgroundColor, textColor) = switch (status) {
      SaleInvoiceStatus.paid => (
        'Paid',
        const Color(0xFFE8F5E9),
        const Color(0xFF2E7D32),
      ),
      SaleInvoiceStatus.unpaid => (
        'Unpaid',
        const Color(0xFFFFEBEE),
        const Color(0xFFC62828),
      ),
      SaleInvoiceStatus.partiallyPaid => (
        'Partial',
        const Color(0xFFFFF3E0),
        const Color(0xFFE65100),
      ),
      SaleInvoiceStatus.overdue => (
        'Overdue',
        const Color(0xFFFCE4EC),
        const Color(0xFFB71C1C),
      ),
      SaleInvoiceStatus.cancelled => (
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
