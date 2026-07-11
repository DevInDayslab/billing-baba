import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:flutter/material.dart';

class EstimateQuotationStatusBadge extends StatelessWidget {
  const EstimateQuotationStatusBadge({
    required this.status,
    this.plain = false,
    super.key,
  });

  final SalesDocumentStatus status;
  final bool plain;

  @override
  Widget build(BuildContext context) {
    final (label, backgroundColor, textColor) = switch (status) {
      SalesDocumentStatus.finalized => (
        'Open',
        const Color(0xFFFFF3E0),
        const Color(0xFFE65100),
      ),
      SalesDocumentStatus.converted => (
        'Converted',
        const Color(0xFFE8F5E9),
        const Color(0xFF2E7D32),
      ),
      SalesDocumentStatus.cancelled => (
        'Cancelled',
        const Color(0xFFF5F5F5),
        const Color(0xFF9E9E9E),
      ),
      SalesDocumentStatus.draft => (
        'Draft',
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
