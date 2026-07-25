import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/features/purchases/application/expenses_provider.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/expenses_category_tab_content.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/expenses_items_tab_content.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_page_title_bar.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/purchase_section_async_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _successSnackBarColor = Color(0xFF2E7D32);

class DesktopExpensesPage extends ConsumerStatefulWidget {
  const DesktopExpensesPage({super.key});

  @override
  ConsumerState<DesktopExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends ConsumerState<DesktopExpensesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(expenseCategoriesProvider.notifier).refresh();
      ref.read(expenseTransactionsProvider.notifier).refresh();
      _showPendingSuccessMessage();
    });
  }

  void _showPendingSuccessMessage() {
    final message = ref.read(expenseSaveSuccessMessageProvider);
    if (message == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _successSnackBarColor,
      ),
    );
    ref.read(expenseSaveSuccessMessageProvider.notifier).setMessage(null);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      ref.read(expenseTabIndexProvider.notifier).tabIndex =
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
    final expensesAsync = ref.watch(expensesPageDataProvider);

    ref.listen<String?>(expenseSaveSuccessMessageProvider, (
      previous,
      next,
    ) {
      if (next == null) return;
      _showPendingSuccessMessage();
    });

    ref.listen<int>(expenseTabIndexProvider, (previous, next) {
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
            const PurchasePageTitleBar(
              currentRoute: AppRoutes.purchaseExpenses,
            ),
            Expanded(
              child: PurchaseSectionAsyncContent(
                expand: true,
                value: expensesAsync,
                onRetry: () {
                  ref.read(expenseCategoriesProvider.notifier).refresh();
                  ref.read(expenseTransactionsProvider.notifier).refresh();
                },
                builder: (_) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.md),
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
                        Tab(text: 'CATEGORY'),
                        Tab(text: 'ITEMS'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: const [
                          ExpensesCategoryTabContent(),
                          ExpensesItemsTabContent(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
