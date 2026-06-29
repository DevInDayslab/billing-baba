import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/models/business_model.dart';
import 'package:billing_baba/features/business/presentation/widgets/business_bottom_bar.dart';
import 'package:billing_baba/features/business/presentation/widgets/business_list.dart';
import 'package:billing_baba/features/business/presentation/widgets/business_list_header.dart';
import 'package:billing_baba/features/business/presentation/widgets/business_toolbar.dart';
import 'package:billing_baba/features/business/providers/business_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BusinessSelectionPage extends ConsumerStatefulWidget {
  const BusinessSelectionPage({super.key});

  @override
  ConsumerState<BusinessSelectionPage> createState() =>
      _BusinessSelectionPageState();
}

class _BusinessSelectionPageState extends ConsumerState<BusinessSelectionPage>
    with SingleTickerProviderStateMixin {
  static const _maxContentWidth = 1050.0;

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openDashboard(BusinessModel business) {
    ref.read(selectedBusinessProvider.notifier).select(business);
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 900;
    final isStackedHeader = screenWidth < 700;
    final outerPadding = isCompact ? AppSpacing.md : AppSpacing.xl;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.all(outerPadding),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                child: Material(
                  elevation: 2,
                  shadowColor: colorScheme.shadow.withValues(alpha: 0.14),
                  color: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.xlBorder,
                    side: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      BusinessListHeader(
                        tabController: _tabController,
                        stacked: isStackedHeader,
                      ),
                      const BusinessToolbar(),
                      Expanded(
                        child: BusinessList(onOpenBusiness: _openDashboard),
                      ),
                      const BusinessBottomBar(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: outerPadding,
            bottom: outerPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logout — coming soon')),
                    );
                  },
                  child: const Text('Logout'),
                ),
                Text(
                  'Logging out will stop syncing data.',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
