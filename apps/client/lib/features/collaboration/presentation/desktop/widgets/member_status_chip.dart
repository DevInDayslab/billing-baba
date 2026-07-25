import 'package:billing_baba/features/collaboration/domain/models/member_status.dart';
import 'package:flutter/material.dart';

class MemberStatusChip extends StatelessWidget {
  const MemberStatusChip({
    required this.status,
    this.isOwner = false,
    this.isCurrentUser = false,
    super.key,
  });

  final MemberStatus status;
  final bool isOwner;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    if (isOwner) {
      return _statusText('Owner', const Color(0xFF1565C0));
    }
    if (isCurrentUser) {
      return _statusText('You', const Color(0xFF6A1B9A));
    }

    final (color, label) = switch (status) {
      MemberStatus.pending => (
        const Color(0xFFE65100),
        'Pending Invitation',
      ),
      MemberStatus.joined => (
        const Color(0xFF2E7D32),
        'Joined',
      ),
      MemberStatus.left => (
        const Color(0xFF757575),
        'Left',
      ),
      MemberStatus.rejected => (
        const Color(0xFFC62828),
        'Rejected',
      ),
      MemberStatus.expired => (
        const Color(0xFF9E9E9E),
        'Expired',
      ),
      MemberStatus.cancelled => (
        const Color(0xFF9E9E9E),
        'Cancelled',
      ),
    };

    return _statusText(label, color);
  }

  Widget _statusText(String label, Color color) {
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
