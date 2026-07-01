import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/categories_tab_content.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/products_tab_content.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/services_tab_content.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/units_tab_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemsPage extends ConsumerStatefulWidget {
  const ItemsPage({super.key});

  @override
  ConsumerState<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends ConsumerState<ItemsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
