import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/dashboard_navigation.dart';
import 'package:billing_baba/features/reports/models/reports_nav_intent.dart';
import 'package:billing_baba/features/reports/models/transaction_report_subsection.dart';
import 'package:billing_baba/features/settings/application/accounting_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Accountant module — accounts and optional journal entries (settings-gated).
class AccountantHubPage extends ConsumerWidget {
  const AccountantHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalEnabled = ref.watch(journalEntriesEnabledProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Accountant'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'Create and review manual accounts and journal-style entries '
            'outside regular sale and purchase transactions.',
            style: AppTypography.inter(
              fontSize: AppTypography.bodyMediumSize,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _HubTile(
            icon: Icons.account_balance_outlined,
            title: 'Accounts',
            subtitle: 'View account balances from Trial Balance report.',
            onTap: () => DashboardNavigation.openReports(
              context,
              ref,
              ReportsNavIntent.transaction(
                TransactionReportSubSection.trialBalance,
              ),
            ),
          ),
          if (journalEnabled) ...[
            const SizedBox(height: AppSpacing.sm),
            _HubTile(
              icon: Icons.menu_book_outlined,
              title: 'Journal entries',
              subtitle: 'Debit and credit accounts manually.',
              onTap: () => context.push(AppRoutes.journalEntries),
            ),
          ],
        ],
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.mdBorder,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.inter(
                        fontSize: AppTypography.bodyLargeSize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.inter(
                        fontSize: AppTypography.bodySmallSize,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
