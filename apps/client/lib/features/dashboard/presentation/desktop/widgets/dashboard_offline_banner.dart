import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardOfflineBanner extends StatelessWidget {
  const DashboardOfflineBanner({
    required this.snapshotSavedAt,
    this.isRefreshing = false,
    super.key,
  });

  final DateTime? snapshotSavedAt;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final updatedLabel = _formatUpdatedAt(snapshotSavedAt);
    final subtitle = isRefreshing
        ? 'Refreshing in the background...'
        : 'Showing last synced data · Updated $updatedLabel';

    return Material(
      color: const Color(0xFFFFF8E1),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(
              isRefreshing ? Icons.sync : Icons.cloud_off_outlined,
              size: 18,
              color: Colors.orange.shade800,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Working offline',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade900.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            if (isRefreshing)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.orange.shade800,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatUpdatedAt(DateTime? time) {
    if (time == null) return 'earlier';
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inDays < 1) return '${diff.inHours} hr ago';
    if (diff.inDays < 7)
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    return DateFormat('d MMM, h:mm a').format(time);
  }
}
