import 'package:billing_baba/features/sales/models/job_work_out_form_model.dart';
import 'package:flutter/material.dart';

const _closedBg = Color(0xFFEEEEEE);
const _closedText = Color(0xFF616161);
const _openBg = Color(0xFFE3F2FD);
const _openText = Color(0xFF1565C0);
const _cancelledBg = Color(0xFFFFEBEE);
const _cancelledText = Color(0xFFC62828);

class JobWorkOutStatusBadge extends StatelessWidget {
  const JobWorkOutStatusBadge({
    required this.status,
    super.key,
  });

  final JobWorkOutStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, backgroundColor, textColor) = switch (status) {
      JobWorkOutStatus.open => ('OPEN', _openBg, _openText),
      JobWorkOutStatus.closed => ('CLOSED', _closedBg, _closedText),
      JobWorkOutStatus.cancelled => ('CANCELLED', _cancelledBg, _cancelledText),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
