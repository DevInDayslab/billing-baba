import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_typography.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/brands_tab_content.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/categories_tab_content.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/products_tab_content.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/services_tab_content.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/units_tab_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Matches inventory tab accent in the reference layout.
const _itemsTabActiveColor = Color(0xFF7C3AED);

const _itemsTabs = [
  _ItemsTabSpec(icon: LucideIcons.package, label: 'Products'),
  _ItemsTabSpec(icon: LucideIcons.settings, label: 'Services'),
  _ItemsTabSpec(icon: LucideIcons.layoutGrid, label: 'Category'),
  _ItemsTabSpec(icon: LucideIcons.tag, label: 'Brand'),
  _ItemsTabSpec(icon: LucideIcons.ruler, label: 'Units'),
];

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
    _tabController = TabController(length: _itemsTabs.length, vsync: this);
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: DashboardColors.border)),
            ),
            child: SizedBox(
              height: DashboardSpacing.topBarHeight,
              child: AnimatedBuilder(
                animation: _tabController,
                builder: (context, _) {
                  return Row(
                    children: [
                      for (var i = 0; i < _itemsTabs.length; i++)
                        Expanded(
                          child: _ItemsTabButton(
                            spec: _itemsTabs[i],
                            isSelected: _tabController.index == i,
                            onTap: () => _tabController.animateTo(i),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                ProductsTabContent(),
                ServicesTabContent(),
                CategoriesTabContent(),
                BrandsTabContent(),
                UnitsTabContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemsTabSpec {
  const _ItemsTabSpec({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _ItemsTabButton extends StatelessWidget {
  const _ItemsTabButton({
    required this.spec,
    required this.isSelected,
    required this.onTap,
  });

  final _ItemsTabSpec spec;
  final bool isSelected;
  final VoidCallback onTap;

  static const _iconTextGap = 8.0;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? _itemsTabActiveColor : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: AppColors.background.withValues(alpha: 0.6),
        child: Container(
          width: double.infinity,
          height: DashboardSpacing.topBarHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? _itemsTabActiveColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(spec.icon, size: 18, color: color),
              const SizedBox(width: _iconTextGap),
              Text(
                spec.label,
                style: DashboardTypography.tabLabel.copyWith(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
