import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/categories_tab_content.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/products_tab_content.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/services_tab_content.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/units_tab_content.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopItemsPage extends ConsumerStatefulWidget {
  const DesktopItemsPage({super.key});

  @override
  ConsumerState<DesktopItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends ConsumerState<DesktopItemsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      ref.read(inventoryItemsTabIndexProvider.notifier).tabIndex =
          _tabController.index;
    }
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(inventoryItemsTabIndexProvider, (previous, next) {
      if (_tabController.index != next && mounted) {
        _tabController.animateTo(next);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: inventoryTabActiveColor,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: inventoryTabActiveColor,
              indicatorWeight: 3,
              dividerColor: inventoryCardBorder,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
              tabs: const [
                Tab(text: 'PRODUCTS'),
                Tab(text: 'SERVICES'),
                Tab(text: 'CATEGORY'),
                Tab(text: 'UNITS'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  ProductsTabContent(),
                  ServicesTabContent(),
                  CategoriesTabContent(),
                  UnitsTabContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
