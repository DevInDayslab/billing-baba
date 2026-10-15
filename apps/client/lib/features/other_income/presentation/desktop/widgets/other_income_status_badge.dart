import 'package:billing_baba/features/other_income/models/other_income_model.dart';
import 'package:flutter/material.dart';

class OtherIncomeStatusBadge extends StatelessWidget {
  const OtherIncomeStatusBadge({
    required this.status,
    this.plain = false,
    super.key,
  });

  final OtherIncomeStatus status;
  final bool plain;

  @override
  Widget build(BuildContext context) {
    final (label, background, textColor) = switch (status) {
      OtherIncomeStatus.paid => (
        'Paid',
        const Color(0xFFE8F5E9),
        const Color(0xFF2E7D32),
      ),
      OtherIncomeStatus.partial => (
        'Partial',
        const Color(0xFFE0F7FA),
        const Color(0xFF00838F),
      ),
      OtherIncomeStatus.pending => (
        'Pending',
        const Color(0xFFFFF3E0),
        const Color(0xFFE65100),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
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
