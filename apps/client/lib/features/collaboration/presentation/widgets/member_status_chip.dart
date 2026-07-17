import 'package:billing_baba/features/collaboration/domain/models/member_status.dart';
import 'package:flutter/material.dart';

class MemberStatusChip extends StatelessWidget {
  const MemberStatusChip({required this.status, super.key});

  final MemberStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      MemberStatus.pending => (
        const Color(0xFFE65100),
        'Pending Invitation',
      ),
      MemberStatus.joined => (
        const Color(0xFF2E7D32),
        'Joined',
      ),
    };

    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
  }
}
