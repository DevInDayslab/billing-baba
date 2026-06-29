import 'package:billing_baba/features/business/providers/business_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BusinessTabs extends ConsumerWidget {
  const BusinessTabs({
    required this.tabController,
    super.key,
    this.dark = false,
  });

  final TabController tabController;
  final bool dark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final labelColor = dark
        ? colorScheme.onInverseSurface
        : colorScheme.primary;
    final unselectedLabelColor = dark
        ? colorScheme.onInverseSurface.withValues(alpha: 0.65)
        : colorScheme.onSurfaceVariant;
    final indicatorColor = dark
        ? colorScheme.onInverseSurface
        : colorScheme.primary;

    return TabBar(
      controller: tabController,
      onTap: (index) {
        ref
            .read(businessTabProvider.notifier)
            .selectTab(
              index == 1 ? BusinessTab.myBusinesses : BusinessTab.sharedWithMe,
            );
        ref.read(selectedBusinessProvider.notifier).clear();
      },
      labelColor: labelColor,
      unselectedLabelColor: unselectedLabelColor,
      indicatorColor: indicatorColor,
      indicatorWeight: 3,
      dividerColor: Colors.transparent,
      labelStyle: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      tabs: const [
        Tab(text: 'Shared With Me'),
        Tab(text: 'My Businesses'),
      ],
    );
  }
}
