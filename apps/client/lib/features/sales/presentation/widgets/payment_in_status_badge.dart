import 'package:billing_baba/features/sales/models/payment_in_model.dart';
import 'package:flutter/material.dart';

class PaymentInStatusBadge extends StatelessWidget {
  const PaymentInStatusBadge({required this.status, super.key});

  final PaymentInStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, textColor) = switch (status) {
      PaymentInStatus.used => ('Used', const Color(0xFF2E7D32)),
      PaymentInStatus.unused => ('Unused', const Color(0xFFC62828)),
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
