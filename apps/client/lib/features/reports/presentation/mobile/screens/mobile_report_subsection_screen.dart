import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/models/report_nav_group_extensions.dart';
import 'package:billing_baba/features/reports/presentation/mobile/application/mobile_report_data_loader.dart';
import 'package:billing_baba/features/reports/presentation/mobile/application/mobile_report_subsection_registry.dart';
import 'package:billing_baba/features/reports/presentation/mobile/models/mobile_report_view_model.dart';
import 'package:billing_baba/features/reports/presentation/mobile/widgets/mobile_report_export_chips.dart';
import 'package:billing_baba/features/reports/presentation/mobile/widgets/mobile_report_filter_header.dart';
import 'package:billing_baba/features/reports/presentation/mobile/widgets/mobile_report_filter_sheet.dart';
import 'package:billing_baba/features/reports/presentation/mobile/widgets/mobile_report_row_card.dart';
import 'package:billing_baba/features/reports/presentation/mobile/widgets/mobile_report_scaffold.dart';
import 'package:billing_baba/features/reports/presentation/mobile/widgets/mobile_report_stat_cards.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_navigation.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Vyapar-style mobile report screen used for all report subsections.
class MobileReportSubsectionScreen extends ConsumerWidget {
  const MobileReportSubsectionScreen({
    required this.groupId,
    required this.subsectionId,
    super.key,
  });

  final String groupId;
  final String subsectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ReportNavGroupExtensions.fromId(groupId);
    final config = group == null
        ? null
        : MobileReportSubsectionRegistry.config(group, subsectionId);

    if (group == null || config == null) {
      return const MobileReportScaffold(
        title: 'Report',
        body: Center(child: Text('Report not found')),
      );
    }

    final reportAsync = MobileReportDataLoader.watch(ref, group, subsectionId);

    return MobileReportScaffold(
      title: config.title,
      actions: [
        reportAsync.maybeWhen(
          data: (data) => _ExportActions(title: config.title, data: data),
          orElse: () => const SizedBox.shrink(),
        ),
      ],
      body: reportAsync.when(
        skipLoadingOnReload: true,
        skipLoadingOnRefresh: true,
        loading: () => const _ReportLoadingBody(),
        error: (error, _) => AppError(
          message: error.toString(),
          onRetry: () => MobileReportDataLoader.refresh(
            ref,
            group,
            subsectionId,
          ),
        ),
        data: (data) => _ReportBody(
          data: data,
          accountFilterKind: config.accountFilterKind,
          onFiltersChanged: () => MobileReportDataLoader.refresh(
            ref,
            group,
            subsectionId,
          ),
        ),
      ),
    );
  }
}

class _ReportLoadingBody extends StatelessWidget {
  const _ReportLoadingBody();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8ECF1),
      highlightColor: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Gap(AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.lgBorder,
              ),
            ),
          ),
          const Gap(AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const Gap(AppSpacing.sm),
                  Expanded(
                    child: Container(
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.mdBorder,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Gap(AppSpacing.lg),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: 4,
              separatorBuilder: (_, _) => const Gap(AppSpacing.sm),
              itemBuilder: (_, _) => Container(
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.lgBorder,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({
    required this.data,
    required this.onFiltersChanged,
    required this.accountFilterKind,
  });

  final MobileReportViewData data;
  final VoidCallback onFiltersChanged;
  final MobileReportAccountFilterKind accountFilterKind;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MobileBottomNavigation.contentBottomPadding(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MobileReportFilterHeader(
          extraChips: data.filterChips,
          accountFilterKind: accountFilterKind,
          onFiltersChanged: onFiltersChanged,
        ),
        if (data.usingMock)
          const MobileReportInfoBanner(
            message:
                'Showing demo data — connect to your business to load live report.',
          ),
        MobileReportStatCards(metrics: data.summaryMetrics),
        if (data.rows.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: Text(
              '${data.totalCount} records',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Expanded(
          child: data.rows.isEmpty
              ? const MobileEmptyState(
                  title: 'No records found',
                  message: 'Try changing the date range or filters.',
                  icon: LucideIcons.receipt,
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    bottomPadding,
                  ),
                  itemCount: data.rows.length,
                  separatorBuilder: (_, _) => const Gap(AppSpacing.sm),
                  itemBuilder: (context, index) {
                    return MobileReportRowCard(row: data.rows[index]);
                  },
                ),
        ),
      ],
    );
  }
}

class _ExportActions extends StatelessWidget {
  const _ExportActions({
    required this.title,
    required this.data,
  });

  final String title;
  final MobileReportViewData data;

  @override
  Widget build(BuildContext context) {
    return MobileReportExportChips(
      onPdf: () => _exportPdf(context),
      onExcel: () => _exportExcel(context),
      onShareWithCa: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Share with CA coming soon')),
        );
      },
    );
  }

  void _exportExcel(BuildContext context) {
    reportExportTable(
      context: context,
      title: title,
      filename: title.toLowerCase().replaceAll(' ', '-'),
      headers: data.exportHeaders.isEmpty
          ? const ['Name', 'Reference', 'Value']
          : data.exportHeaders,
      rows: _exportRows(),
    );
  }

  void _exportPdf(BuildContext context) {
    reportPrintTable(
      context: context,
      title: title,
      headers: data.exportHeaders.isEmpty
          ? const ['Name', 'Reference', 'Value']
          : data.exportHeaders,
      rows: _exportRows(),
    );
  }

  List<List<String>> _exportRows() {
    if (data.exportRows.isNotEmpty) return data.exportRows;
    return [
      for (final row in data.rows)
        [
          row.title,
          row.reference,
          ...row.columns.map((column) => column.value),
        ],
    ];
  }
}
