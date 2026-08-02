import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/reports_nav_catalog.dart';
import 'package:billing_baba/features/reports/models/report_nav_group.dart';
import 'package:billing_baba/features/reports/models/report_nav_group_extensions.dart';
import 'package:billing_baba/features/reports/presentation/mobile/widgets/mobile_report_list_tile.dart';
import 'package:billing_baba/features/reports/presentation/mobile/widgets/mobile_report_scaffold.dart';
import 'package:billing_baba/features/reports/presentation/mobile/widgets/mobile_report_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_navigation.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Mobile reports hub — lists all report categories from the desktop app.
class MobileReportsHubScreen extends StatelessWidget {
  const MobileReportsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = ReportsNavCatalog.groups;
    final bottomPadding = MobileBottomNavigation.contentBottomPadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MobileAppBar(
        title: 'Reports',
        showBackButton: true,
        showBusinessHeader: false,
        showNotification: false,
        showSettings: false,
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: bottomPadding),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: MobileCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          MobileReportTheme.accent.withValues(alpha: 0.18),
                          MobileReportTheme.iconTint.withValues(alpha: 0.12),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.assessment_outlined,
                      color: MobileReportTheme.accent,
                    ),
                  ),
                  const Gap(AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Business Reports',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const Gap(4),
                        Text(
                          '${groups.length} categories · ${groups.fold<int>(0, (sum, g) => sum + ReportsNavCatalog.subsectionsFor(g).length)} reports',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const MobileReportSectionHeader(label: 'Report Categories'),
          for (var i = 0; i < groups.length; i++) ...[
            _GroupTile(
              group: groups[i],
              reportCount: ReportsNavCatalog.subsectionsFor(groups[i]).length,
            ),
            if (i < groups.length - 1) const Gap(AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.group,
    required this.reportCount,
  });

  final ReportNavGroup group;
  final int reportCount;

  @override
  Widget build(BuildContext context) {
    return MobileReportListTile(
      title: group.label,
      subtitle: group.subtitle,
      icon: group.icon,
      trailingLabel: '$reportCount',
      onTap: () => context.push(AppRoutes.settingsReportGroup(group.id)),
    );
  }
}
