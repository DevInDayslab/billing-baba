import 'package:billing_baba/features/sales/models/sale_fa_model.dart';
import 'package:flutter/material.dart';

class SaleFaStatusBadge extends StatelessWidget {
  const SaleFaStatusBadge({required this.status, super.key});

  final SaleFaStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, textColor) = switch (status) {
      SaleFaStatus.paid => ('Paid', const Color(0xFF2E7D32)),
      SaleFaStatus.unpaid => ('Unpaid', const Color(0xFF1565C0)),
      SaleFaStatus.partiallyPaid => ('Partial', const Color(0xFF1565C0)),
      SaleFaStatus.overdue => ('Overdue', const Color(0xFFE65100)),
      SaleFaStatus.cancelled => ('Cancelled', const Color(0xFF9E9E9E)),
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
