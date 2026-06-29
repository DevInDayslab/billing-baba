import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/models/business_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BusinessCard extends StatelessWidget {
  const BusinessCard({
    required this.business,
    required this.isSelected,
    required this.onSelect,
    required this.onOpen,
    super.key,
  });

  final BusinessModel business;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onOpen;

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _timeFormat = DateFormat('hh:mm a');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.12)
          : colorScheme.surface,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSelect,
          onDoubleTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              business.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: AppSpacing.sm),
                            const _CurrentBusinessBadge(),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Last sale created: ${_dateFormat.format(business.lastOpenedAt)} '
                        'at ${_timeFormat.format(business.lastOpenedAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                _SyncStatus(isOfflineReady: business.isOfflineReady),
                const SizedBox(width: AppSpacing.lg),
                OutlinedButton(
                  onPressed: onOpen,
                  child: const Text('Open'),
                ),
                const SizedBox(width: AppSpacing.xs),
                _BusinessMoreMenu(business: business),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrentBusinessBadge extends StatelessWidget {
  const _CurrentBusinessBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: AppRadius.smBorder,
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: Text(
        'Current Business',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: const Color(0xFFE65100),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SyncStatus extends StatelessWidget {
  const _SyncStatus({required this.isOfflineReady});

  final bool isOfflineReady;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = isOfflineReady ? 'Sync on' : 'Offline';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.computer_outlined,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _BusinessMoreMenu extends StatelessWidget {
  const _BusinessMoreMenu({required this.business});

  final BusinessModel business;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'More options',
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$value — coming soon')),
        );
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'Rename', child: Text('Rename')),
        const PopupMenuItem(value: 'Backup', child: Text('Backup')),
        const PopupMenuItem(value: 'Remove', child: Text('Remove')),
      ],
    );
  }
}
