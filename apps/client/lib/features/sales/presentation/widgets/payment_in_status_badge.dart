import 'package:billing_baba/features/sales/models/payment_in_model.dart';
import 'package:flutter/material.dart';

class PaymentInStatusBadge extends StatelessWidget {
  const PaymentInStatusBadge({
    required this.status,
    this.plain = true,
    super.key,
  });

  final PaymentInStatus status;
  final bool plain;

  @override
  Widget build(BuildContext context) {
    final (label, textColor) = switch (status) {
      PaymentInStatus.paid => ('Paid', const Color(0xFF2E7D32)),
      PaymentInStatus.partial => ('Partial', const Color(0xFFE65100)),
      PaymentInStatus.unused => ('Unused', const Color(0xFFC62828)),
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
        color: textColor.withValues(alpha: 0.12),
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
