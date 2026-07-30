import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_icon_action_button.dart';
import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_transaction_list_controller.dart';
import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_transaction_models.dart';
import 'package:billing_baba/shared/widgets/mobile/transaction/widgets/mobile_transaction_card.dart';
import 'package:billing_baba/shared/widgets/mobile/transaction/widgets/mobile_transaction_sheets.dart';
import 'package:billing_baba/shared/widgets/mobile/transaction/widgets/mobile_transaction_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef MobileTransactionItemBuilder =
    Widget Function(
      BuildContext context,
      MobileTransactionListItem item,
      VoidCallback onTap,
    );

typedef MobileTransactionFilterMatcher =
    bool Function(MobileTransactionListItem item, String filterKey);

/// Reusable mobile transaction list page for sales, purchases, and related flows.
class MobileTransactionPage extends ConsumerStatefulWidget {
  const MobileTransactionPage({
    required this.config,
    required this.itemsAsync,
    super.key,
    this.onRefresh,
    this.onSearchChanged,
    this.onFilterChanged,
    this.onItemTap,
    this.filterMatcher,
    this.itemBuilder,
    this.footer,
    this.searchDebounce = const Duration(milliseconds: 300),
  });

  final MobileTransactionPageConfig config;
  final AsyncValue<List<MobileTransactionListItem>> itemsAsync;
  final Future<void> Function()? onRefresh;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String?>? onFilterChanged;
  final ValueChanged<MobileTransactionListItem>? onItemTap;
  final MobileTransactionFilterMatcher? filterMatcher;
  final MobileTransactionItemBuilder? itemBuilder;
  final Widget? footer;
  final Duration searchDebounce;

  @override
  ConsumerState<MobileTransactionPage> createState() =>
      _MobileTransactionPageState();
}

class _MobileTransactionPageState extends ConsumerState<MobileTransactionPage> {
  late final TextEditingController _searchController;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    final scope = widget.config.scopeId;
    final initialQuery = ref.read(
      mobileTransactionListStateProvider(scope),
    );
    _searchController = TextEditingController(text: initialQuery.searchQuery);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final registry = ref.read(mobileTransactionListRegistryProvider.notifier);
      if (widget.config.defaultFilterKey != null) {
        registry.setFilter(scope, widget.config.defaultFilterKey);
      }
      registry.setSort(scope, widget.config.defaultSort);
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final scope = widget.config.scopeId;
    ref
        .read(mobileTransactionListRegistryProvider.notifier)
        .setSearch(scope, query);

    _searchDebounce?.cancel();
    _searchDebounce = Timer(widget.searchDebounce, () {
      widget.onSearchChanged?.call(query.trim());
    });
  }

  String _filterLabel(MobileTransactionListState state) {
    if (!state.hasActiveFilter) return 'Filter';
    final key = state.filterKey!;
    for (final option in widget.config.filterOptions) {
      if (option.key == key) return option.label;
    }
    return key;
  }

  List<MobileTransactionListItem> _prepareItems(
    List<MobileTransactionListItem> items,
    MobileTransactionListState listState,
  ) {
    final filtered = filterMobileTransactionItems(
      items: items,
      query: listState.searchQuery,
      filterKey: listState.filterKey,
      filterMatcher: widget.filterMatcher,
    );
    return sortMobileTransactionItems(filtered, listState.sort);
  }

  @override
  Widget build(BuildContext context) {
    final scope = widget.config.scopeId;
    final listState = ref.watch(
      mobileTransactionListStateProvider(scope),
    );
    final config = widget.config;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MobileAppBar(
        title: config.title,
        showBusinessHeader: config.showBusinessHeader,
        showNotification: config.showNotification,
        onSettingsTap: config.onSettingsTap,
        actions: [
          ...?config.appBarActions,
          if (config.moreActions.isNotEmpty)
            MobileIconActionButton(
              icon: Icons.more_horiz_rounded,
              tooltip: 'More actions',
              onPressed: () => showMobileTransactionMoreActionsSheet(
                context: context,
                actions: config.moreActions,
              ),
            ),
        ],
      ),
      floatingActionButton: config.onFabPressed == null
          ? null
          : FloatingActionButton(
              onPressed: config.onFabPressed,
              tooltip: config.fabTooltip,
              child: Icon(config.fabIcon),
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MobileTransactionToolbar(
            searchController: _searchController,
            searchHint: config.searchHint,
            onSearchChanged: _onSearchChanged,
            sortState: listState.sort,
            sortFieldLabels: config.sortFieldOptions,
            filterLabel: _filterLabel(listState),
            isFilterActive: listState.hasActiveFilter,
            showMoreButton: config.moreActions.isNotEmpty,
            onMoreTap: config.moreActions.isEmpty
                ? null
                : () => showMobileTransactionMoreActionsSheet(
                    context: context,
                    actions: config.moreActions,
                  ),
            onFilterTap: () async {
              final result = await showMobileTransactionFilterSheet(
                context: context,
                options: config.filterOptions,
                selectedKey: listState.filterKey ?? MobileFilterOption.allKey,
              );
              if (result == null) return;
              ref
                  .read(mobileTransactionListRegistryProvider.notifier)
                  .setFilter(scope, result);
              widget.onFilterChanged?.call(
                result == MobileFilterOption.allKey ? null : result,
              );
            },
            onSortTap: () async {
              final result = await showMobileTransactionSortSheet(
                context: context,
                selected: listState.sort,
                fieldOptions: config.sortFieldOptions,
              );
              if (result == null) return;
              ref
                  .read(mobileTransactionListRegistryProvider.notifier)
                  .setSort(scope, result);
            },
          ),
          Expanded(
            child: widget.itemsAsync.when(
              loading: () => _TransactionListLoader(
                onRefresh: widget.onRefresh,
              ),
              error: (error, _) => AppError(
                message: error.toString(),
                onRetry: widget.onRefresh == null
                    ? null
                    : () => unawaited(widget.onRefresh!()),
              ),
              data: (items) {
                final prepared = _prepareItems(items, listState);
                if (prepared.isEmpty) {
                  final empty = config.emptyState;
                  return MobileEmptyState(
                    title: empty.title,
                    message: empty.message,
                    icon: empty.icon,
                    actionLabel: empty.actionLabel,
                    onAction: empty.onAction,
                  );
                }

                return RefreshIndicator(
                  onRefresh: widget.onRefresh ?? () async {},
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.xxxl,
                    ),
                    itemCount: prepared.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final item = prepared[index];
                      void onTap() => widget.onItemTap?.call(item);

                      if (widget.itemBuilder != null) {
                        return widget.itemBuilder!(context, item, onTap);
                      }

                      return MobileTransactionCard(
                        item: item,
                        onTap: widget.onItemTap == null ? () {} : onTap,
                      );
                    },
                  ),
                );
              },
            ),
          ),
          if (widget.footer != null) widget.footer!,
        ],
      ),
    );
  }
}

class _TransactionListLoader extends StatelessWidget {
  const _TransactionListLoader({this.onRefresh});

  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
