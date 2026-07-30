import 'package:billing_baba/features/purchases/models/payment_out_model.dart';
import 'package:flutter/material.dart';

class PaymentOutStatusBadge extends StatelessWidget {
  const PaymentOutStatusBadge({required this.status, super.key});

  final PaymentOutStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, textColor) = switch (status) {
      PaymentOutStatus.paid => ('Paid', const Color(0xFF2E7D32)),
      PaymentOutStatus.pending => ('Pending', const Color(0xFFE65100)),
      PaymentOutStatus.cancelled => ('Cancelled', const Color(0xFFC62828)),
    };

    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
    );
  }
}
