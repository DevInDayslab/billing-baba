import 'package:billing_baba/features/purchases/models/purchase_fa_model.dart';
import 'package:flutter/material.dart';

class PurchaseFaStatusBadge extends StatelessWidget {
  const PurchaseFaStatusBadge({required this.status, super.key});

  final PurchaseFaStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, backgroundColor, textColor) = switch (status) {
      PurchaseFaStatus.paid => (
        'Paid',
        const Color(0xFFE8F5E9),
        const Color(0xFF2E7D32),
      ),
      PurchaseFaStatus.unpaid => (
        'Unpaid',
        const Color(0xFFE3F2FD),
        const Color(0xFF1565C0),
      ),
      PurchaseFaStatus.partiallyPaid => (
        'Partial',
        const Color(0xFFE3F2FD),
        const Color(0xFF1565C0),
      ),
      PurchaseFaStatus.overdue => (
        'Overdue',
        const Color(0xFFFFF3E0),
        const Color(0xFFE65100),
      ),
      PurchaseFaStatus.cancelled => (
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
