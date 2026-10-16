import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_typography.dart';
import 'package:billing_baba/features/other_income/application/other_incomes_provider.dart';
import 'package:billing_baba/features/other_income/presentation/desktop/widgets/other_income_category_tab_content.dart';
import 'package:billing_baba/features/other_income/presentation/desktop/widgets/other_income_items_tab_content.dart';
import 'package:billing_baba/features/other_income/presentation/desktop/widgets/other_income_page_title_bar.dart';
import 'package:billing_baba/features/other_income/presentation/desktop/widgets/other_income_section_async_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _successSnackBarColor = Color(0xFF2E7D32);

class DesktopOtherIncomesPage extends ConsumerStatefulWidget {
  const DesktopOtherIncomesPage({this.embeddedInAccountsHub = false, super.key});

  final bool embeddedInAccountsHub;

  @override
  ConsumerState<DesktopOtherIncomesPage> createState() => _OtherIncomesPageState();
}

class _OtherIncomesPageState extends ConsumerState<DesktopOtherIncomesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPendingSuccessMessage();
    });
  }

  void _showPendingSuccessMessage() {
    final message = ref.read(otherIncomeSaveSuccessMessageProvider);
    if (message == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _successSnackBarColor,
      ),
    );
    ref.read(otherIncomeSaveSuccessMessageProvider.notifier).setMessage(null);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      ref.read(otherIncomeTabIndexProvider.notifier).tabIndex =
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
    final expensesAsync = ref.watch(otherIncomesPageDataProvider);

    ref.listen<String?>(otherIncomeSaveSuccessMessageProvider, (
      previous,
      next,
    ) {
      if (next == null) return;
      _showPendingSuccessMessage();
    });

    ref.listen<int>(otherIncomeTabIndexProvider, (previous, next) {
      if (_tabController.index != next && mounted) {
        _tabController.animateTo(next);
      }
    });

    final tabViews = TabBarView(
      controller: _tabController,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        OtherIncomeCategoryTabContent(),
        OtherIncomeItemsTabContent(),
      ],
    );

    final asyncTabContent = OtherIncomeSectionAsyncContent(
      expand: true,
      value: expensesAsync,
      onRetry: () {
        ref.read(incomeCategoriesProvider.notifier).refresh();
        ref.read(otherIncomeTransactionsProvider.notifier).refresh();
      },
      builder: (_) => tabViews,
    );

    if (widget.embeddedInAccountsHub) {
      return ColoredBox(
        color: AppColors.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _EmbeddedOtherIncomeViewToggle(),
            Expanded(child: asyncTabContent),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const OtherIncomePageTitleBar(
              currentRoute: AppRoutes.otherIncome,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: _OtherIncomeCategoryItemsToggle(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(child: asyncTabContent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmbeddedOtherIncomeViewToggle extends StatelessWidget {
  const _EmbeddedOtherIncomeViewToggle();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: DashboardColors.border)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: _OtherIncomeCategoryItemsToggle(),
        ),
      ),
    );
  }
}

class _OtherIncomeCategoryItemsToggle extends ConsumerWidget {
  const _OtherIncomeCategoryItemsToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(otherIncomeTabIndexProvider);

    return SegmentedButton<int>(
      segments: const [
        ButtonSegment(value: 0, label: Text('Category')),
        ButtonSegment(value: 1, label: Text('Items')),
      ],
      selected: {selected},
      onSelectionChanged: (selection) {
        if (selection.isEmpty) return;
        ref.read(otherIncomeTabIndexProvider.notifier).tabIndex =
            selection.first;
      },
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: WidgetStatePropertyAll(
          DashboardTypography.tabLabel.copyWith(fontSize: 13),
        ),
      ),
    );
  }
}
