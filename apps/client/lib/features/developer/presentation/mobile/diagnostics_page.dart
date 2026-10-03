import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/sync/models/sync_state.dart';
import 'package:billing_baba/core/sync/providers/sync_providers.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class MobileDiagnosticsPage extends ConsumerWidget {
  const MobileDiagnosticsPage({super.key});

  static final _timeFormat = DateFormat('dd MMM yyyy, hh:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(syncPendingCountProvider);
    final pendingJobs = ref.watch(syncPendingJobsProvider);
    final syncState = ref.watch(syncStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MobileAppBar(
        title: 'Diagnostics',
        showBusinessHeader: false,
        showNotification: false,
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(syncPendingJobsProvider);
              ref.invalidate(syncPendingCountProvider);
              ref.invalidate(syncStateProvider);
            },
            icon: const Icon(LucideIcons.refreshCw),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _Section(
            title: 'Environment',
            children: [
              _InfoRow('API URL', AppConfig.apiBaseUrl),
              _InfoRow('APP_ENV', dotenv.env['APP_ENV'] ?? '(unset)'),
              _InfoRow('WEBSITE_URL', AppConfig.websiteUrl),
              _InfoRow('GIT_COMMIT', AppConfig.gitCommit),
              _InfoRow('ENABLE_DEV_LOGIN', '${AppConfig.enableDevLogin}'),
            ],
          ),
          _Section(
            title: 'Sync',
            children: [
              _InfoRow(
                'Connectivity',
                _connectivityLabel(syncState.value?.connectivity),
              ),
              _InfoRow(
                'Lifecycle',
                syncState.value?.lifecycle.name ?? 'unknown',
              ),
              _InfoRow(
                'Pending jobs',
                pendingCount.when(
                  data: (count) => '$count',
                  loading: () => '…',
                  error: (_, _) => '—',
                ),
              ),
              _InfoRow(
                'Last sync',
                syncState.value?.lastSyncTime != null
                    ? _timeFormat.format(syncState.value!.lastSyncTime!)
                    : '—',
              ),
              if (syncState.value?.errorMessage != null)
                _InfoRow('Error', syncState.value!.errorMessage!),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Sync queue',
            style: AppTypography.inter(
              fontSize: AppTypography.bodySize,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          pendingJobs.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text(
              error.toString(),
              style: AppTypography.inter(
                fontSize: AppTypography.bodySize,
                color: AppColors.error,
              ),
            ),
            data: (jobs) {
              if (jobs.isEmpty) {
                return Text(
                  'No pending sync jobs',
                  style: AppTypography.inter(
                    fontSize: AppTypography.bodySize,
                    color: AppColors.textSecondary,
                  ),
                );
              }
              return Column(
                children: jobs.take(50).map((job) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ListTile(
                      dense: true,
                      title: Text(
                        '${job.entityType} · ${job.operation.wire}',
                        style: AppTypography.inter(
                          fontSize: AppTypography.bodySize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        '${job.status.wire} · ${job.kind.wire}',
                        style: AppTypography.inter(
                          fontSize: AppTypography.captionSize,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: job.lastError != null
                          ? const Icon(
                              LucideIcons.circleAlert,
                              color: AppColors.error,
                              size: 18,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  static String _connectivityLabel(SyncConnectivityStatus? status) {
    return switch (status) {
      SyncConnectivityStatus.online => 'Online',
      SyncConnectivityStatus.offline => 'Offline',
      SyncConnectivityStatus.unknown => 'Unknown',
      null => 'Unknown',
    };
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: AppTypography.inter(
            fontSize: AppTypography.bodySize,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(children: children),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.inter(
                fontSize: AppTypography.bodySize,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTypography.inter(
                fontSize: AppTypography.bodySize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
