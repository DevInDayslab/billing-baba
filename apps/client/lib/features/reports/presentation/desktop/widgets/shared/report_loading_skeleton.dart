import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Desktop report first-load placeholder — avoids showing raw errors during
/// brief provider warm-up races.
class ReportLoadingSkeleton extends StatelessWidget {
  const ReportLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE8ECF1),
        highlightColor: const Color(0xFFF8FAFC),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.mdBorder,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.mdBorder,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.sm),
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
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView.separated(
                  itemCount: 6,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, _) => Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.smBorder,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
