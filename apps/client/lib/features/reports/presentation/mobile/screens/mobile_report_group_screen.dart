import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/mobile_report_navigation.dart';
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

/// Mobile report group screen — lists subsections for a report category.
class MobileReportGroupScreen extends StatelessWidget {
  const MobileReportGroupScreen({
    required this.groupId,
    super.key,
  });

  final String groupId;

  @override
  Widget build(BuildContext context) {
    final group = ReportNavGroupExtensions.fromId(groupId);
    if (group == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const MobileAppBar(
          title: 'Reports',
          showBackButton: true,
          showBusinessHeader: false,
          showNotification: false,
          showSettings: false,
        ),
        body: const Center(child: Text('Report category not found')),
      );
    }

    final subsections = ReportsNavCatalog.subsectionsFor(group);
    final bottomPadding = MobileBottomNavigation.contentBottomPadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MobileAppBar(
        title: group.label,
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
                          MobileReportTheme.iconTint.withValues(alpha: 0.16),
                          MobileReportTheme.accent.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(group.icon, color: MobileReportTheme.iconTint),
                  ),
                  const Gap(AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.label,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const Gap(4),
                        Text(
                          group.subtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.35,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          MobileReportSectionHeader(
            label: 'Available Reports',
            trailing: '${subsections.length} total',
          ),
          for (var i = 0; i < subsections.length; i++) ...[
            MobileReportListTile(
              title: subsections[i].label,
              showNotificationDot: subsections[i].showNotificationDot,
              onTap: () => _openSubsection(context, group, subsections[i].id),
            ),
            if (i < subsections.length - 1) const Gap(AppSpacing.sm),
          ],
        ],
      ),
    );
  }

  void _openSubsection(
    BuildContext context,
    ReportNavGroup group,
    String subsectionId,
  ) {
    final route = MobileReportNavigation.routeFor(group, subsectionId);
    context.push(route);
  }
}
