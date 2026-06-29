import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/providers/business_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BusinessToolbar extends ConsumerWidget {
  const BusinessToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tab = ref.watch(businessTabProvider);

    final subtitle = tab == BusinessTab.myBusinesses
        ? 'Below are the businesses created by you.'
        : 'Below are the businesses shared with you.';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Browse backup files — coming soon'),
                ),
              );
            },
            child: const Text('Browse Files (.bb)'),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton.filledTonal(
            tooltip: 'Refresh',
            onPressed: () => ref.read(businessListProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh, size: 20),
          ),
        ],
      ),
    );
  }
}
