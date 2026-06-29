import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/presentation/widgets/business_search_bar.dart';
import 'package:billing_baba/features/business/presentation/widgets/business_tabs.dart';
import 'package:flutter/material.dart';

class BusinessListHeader extends StatelessWidget {
  const BusinessListHeader({
    required this.tabController,
    required this.stacked,
    super.key,
  });

  final TabController tabController;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onHeader = theme.colorScheme.onInverseSurface;

    return ColoredBox(
      color: theme.colorScheme.inverseSurface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (stacked)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Business List',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: onHeader,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const BusinessSearchBar(compact: true, dark: true),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Business List',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: onHeader,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  const BusinessSearchBar(dark: true),
                ],
              ),
            const SizedBox(height: AppSpacing.md),
            BusinessTabs(tabController: tabController, dark: true),
          ],
        ),
      ),
    );
  }
}
