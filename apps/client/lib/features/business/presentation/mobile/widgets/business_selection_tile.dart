import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/presentation/desktop/widgets/business_avatar.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_list_entry.dart';
import 'package:flutter/material.dart';

/// Selectable business row for the mobile company picker (Vyapar-style).
class BusinessSelectionTile extends StatelessWidget {
  const BusinessSelectionTile({
    required this.entry,
    required this.isSelected,
    required this.onTap,
    super.key,
    this.enabled = true,
  });

  final CompanyListEntry entry;
  final bool isSelected;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = _subtitleFor(entry);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: AppRadius.lgBorder,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.lgBorder,
            border: Border.all(
              color: isSelected ? AppColors.primary : const Color(0xFFE8EAED),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isSelected ? 0.08 : 0.04,
                ),
                blurRadius: isSelected ? 12 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              BusinessAvatar(
                name: entry.name,
                seed: entry.id,
                diameter: 48,
                logoUrl: entry.logoUrl,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: enabled
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (entry.isCurrent) ...[
                      const SizedBox(height: AppSpacing.xs),
                      const _ActiveBadge(label: 'Active'),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _SelectionIndicator(
                isSelected: isSelected,
                enabled: enabled,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _subtitleFor(CompanyListEntry entry) {
    if (entry.isSharedTab) {
      final owner = entry.ownerName ?? 'Business owner';
      return 'Shared by $owner';
    }
    if (entry.gstin != null && entry.gstin!.trim().isNotEmpty) {
      return 'GSTIN: ${entry.gstin}';
    }
    if (entry.ownerName != null && entry.ownerName!.trim().isNotEmpty) {
      return entry.ownerName;
    }
    return null;
  }
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: AppRadius.smBorder,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({
    required this.isSelected,
    required this.enabled,
  });

  final bool isSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = !enabled
        ? AppColors.textSecondary.withValues(alpha: 0.4)
        : isSelected
        ? AppColors.primary
        : AppColors.textSecondary.withValues(alpha: 0.5);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: Icon(
        isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
        key: ValueKey(isSelected),
        color: color,
        size: AppIconSize.xl,
      ),
    );
  }
}
