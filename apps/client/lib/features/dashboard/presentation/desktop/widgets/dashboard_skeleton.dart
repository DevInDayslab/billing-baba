import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_typography.dart';
import 'package:billing_baba/shared/layout/dashboard_layout.dart';
import 'package:flutter/material.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = DashboardLayoutScope.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: metrics.mainWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: metrics.kpiRowHeight,
                child: Row(
                  children: [
                    const Expanded(child: _SkeletonCard()),
                    SizedBox(width: metrics.gap),
                    const Expanded(child: _SkeletonCard()),
                  ],
                ),
              ),
              SizedBox(height: metrics.gap),
              SizedBox(
                height: metrics.chartRowHeight,
                child: Row(
                  children: [
                    Expanded(
                      flex: metrics.chartColumnFlex,
                      child: const _SkeletonCard(tall: true),
                    ),
                    SizedBox(width: metrics.gap),
                    Expanded(
                      flex: metrics.todoColumnFlex,
                      child: const _SkeletonCard(tall: true),
                    ),
                  ],
                ),
              ),
              SizedBox(height: metrics.gap),
              SizedBox(
                height: metrics.reportsRowHeight,
                child: const _SkeletonCard(),
              ),
            ],
          ),
        ),
        SizedBox(width: metrics.gap),
        SizedBox(
          width: metrics.sideWidth,
          child: Column(
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: DashboardDecor.cardRadius,
                    border: Border.all(color: DashboardColors.border),
                  ),
                  child: const Column(
                    children: [
                      Expanded(child: _SkeletonCard(compact: true, borderless: true)),
                      Divider(height: 1, color: DashboardColors.divider),
                      Expanded(child: _SkeletonCard(compact: true, borderless: true)),
                      Divider(height: 1, color: DashboardColors.divider),
                      Expanded(child: _SkeletonCard(compact: true, borderless: true)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: metrics.gap),
              const _SkeletonCard(picker: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({
    this.tall = false,
    this.compact = false,
    this.borderless = false,
    this.picker = false,
  });

  final bool tall;
  final bool compact;
  final bool borderless;
  final bool picker;

  @override
  Widget build(BuildContext context) {
    final metrics = DashboardLayoutScope.of(context);
    final padding = compact || picker ? metrics.padding * 0.65 : metrics.padding;

    final content = Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: picker ? 140 : (compact ? 72 : 110),
            height: picker ? 10 : 11,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: DashboardDecor.cardRadius,
            ),
          ),
          if (!picker) ...[
            SizedBox(height: metrics.gap * 0.5),
            Container(
              width: compact ? 80 : 120,
              height: compact ? 16 : 20,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: DashboardDecor.cardRadius,
              ),
            ),
          ],
          if (tall) ...[
            SizedBox(height: metrics.gap * 0.5),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: DashboardDecor.cardRadius,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (borderless) return content;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: DashboardDecor.cardRadius,
        border: Border.all(color: DashboardColors.border),
        boxShadow: DashboardDecor.cardShadow,
      ),
      child: content,
    );
  }
}
