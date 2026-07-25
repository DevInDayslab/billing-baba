import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/crm/application/lead_detail_provider.dart';
import 'package:billing_baba/features/crm/domain/models/lead.dart';
import 'package:billing_baba/features/crm/presentation/desktop/widgets/lead_activity_table.dart';
import 'package:billing_baba/features/crm/presentation/desktop/widgets/lead_status_chip.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_detail_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class LeadDetailPanel extends ConsumerWidget {
  const LeadDetailPanel({
    required this.leadId,
    this.onBack,
    super.key,
  });

  final String leadId;
  final VoidCallback? onBack;

  static final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(leadDetailProvider(leadId));

    return detailAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _LeadDetailError(
        message: error.toString(),
        onRetry: () => ref.invalidate(leadDetailProvider(leadId)),
      ),
      data: (detail) {
        if (detail == null) {
          return const Center(
            child: Text(
              'Lead not found',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        final lead = detail.lead;
        final lastActivity = detail.activities.isNotEmpty
            ? detail.activities.first.createdAt
            : null;

        return Column(
          key: ValueKey(lead.id),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (onBack != null) ...[
                        IconButton(
                          onPressed: onBack,
                          icon: const Icon(Icons.arrow_back),
                          tooltip: 'Back',
                        ),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      Expanded(
                        child: Text(
                          lead.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InventoryDetailMetaLine(
                              label: 'Phone Number',
                              value: LeadX.displayOrDash(lead.phone),
                            ),
                            InventoryDetailMetaLine(
                              label: 'Email',
                              value: LeadX.displayOrDash(lead.email),
                            ),
                            InventoryDetailMetaLine(
                              label: 'Lead Source',
                              value: lead.displayLeadSource,
                            ),
                            InventoryDetailMetaLine(
                              label: 'Company',
                              value: lead.displayCompany,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: Row(
                                children: [
                                  const Text(
                                    'STATUS: ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  LeadStatusChip(status: lead.status),
                                ],
                              ),
                            ),
                            InventoryDetailMetaLine(
                              label: 'Assigned To',
                              value: lead.displayAssignedTo,
                            ),
                            InventoryDetailMetaLine(
                              label: 'Created Date',
                              value: _dateFormat.format(
                                lead.createdAt.toLocal(),
                              ),
                            ),
                            InventoryDetailMetaLine(
                              label: 'Last Activity',
                              value: lastActivity == null
                                  ? '—'
                                  : _dateFormat.format(lastActivity.toLocal()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Text(
                'Activities',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: LeadActivityTable(activities: detail.activities),
            ),
          ],
        );
      },
    );
  }
}

class _LeadDetailError extends StatelessWidget {
  const _LeadDetailError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: const TextStyle(color: AppColors.error)),
          const SizedBox(height: AppSpacing.sm),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
