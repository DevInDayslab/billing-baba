import 'package:billing_baba/features/crm/domain/models/lead.dart';
import 'package:flutter/material.dart';

class LeadStatusChip extends StatelessWidget {
  const LeadStatusChip({
    required this.status,
    this.plain = false,
    super.key,
  });

  final LeadStatus status;
  final bool plain;

  @override
  Widget build(BuildContext context) {
    final (label, backgroundColor, textColor) = switch (status) {
      LeadStatus.newLead => (
        'New',
        const Color(0xFFF5F5F5),
        const Color(0xFF757575),
      ),
      LeadStatus.contacted => (
        'Contacted',
        const Color(0xFFFFF3E0),
        const Color(0xFFE65100),
      ),
      LeadStatus.qualified => (
        'Qualified',
        const Color(0xFFFFF3E0),
        const Color(0xFFE65100),
      ),
      LeadStatus.converted => (
        'Converted',
        const Color(0xFFE8F5E9),
        const Color(0xFF2E7D32),
      ),
      LeadStatus.lost => (
        'Lost',
        const Color(0xFFFFEBEE),
        const Color(0xFFC62828),
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

class LeadSourceBadge extends StatelessWidget {
  const LeadSourceBadge({
    required this.source,
    super.key,
  });

  final LeadSource? source;

  @override
  Widget build(BuildContext context) {
    if (source == null) {
      return const SizedBox.shrink();
    }

    final color = switch (source!) {
      LeadSource.googleAds => const Color(0xFF1565C0),
      LeadSource.referral => const Color(0xFF7B1FA2),
      LeadSource.website => const Color(0xFF00897B),
      LeadSource.walkIn => const Color(0xFFEF6C00),
      LeadSource.other => const Color(0xFF757575),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          source!.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
