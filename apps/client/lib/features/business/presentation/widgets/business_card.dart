import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/models/business_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BusinessCard extends StatelessWidget {
  const BusinessCard({
    required this.business,
    required this.onOpen,
    super.key,
  });

  final BusinessModel business;
  final VoidCallback onOpen;

  static const _currentBadgeColor = Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("dd/MM/yyyy 'at' hh:mm a");

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ),
                    if (business.isCurrent) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: _currentBadgeColor.withValues(alpha: 0.12),
                          borderRadius: AppRadius.smBorder,
                          border: Border.all(color: _currentBadgeColor),
                        ),
                        child: const Text(
                          'Current Company',
                          style: TextStyle(
                            color: _currentBadgeColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (business.lastSaleAt != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Last sale: ${dateFormat.format(business.lastSaleAt!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.monitor,
                      size: 16,
                      color: business.syncStatus == SyncStatus.on
                          ? Colors.green
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      business.syncStatus == SyncStatus.on
                          ? 'SYNC ON'
                          : 'SYNC OFF',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: business.syncStatus == SyncStatus.on
                            ? Colors.green
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onOpen,
            child: const Text('Open'),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
