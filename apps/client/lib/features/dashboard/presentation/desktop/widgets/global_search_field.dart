import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/utils/debouncer.dart';
import 'package:billing_baba/features/dashboard/models/global_search_result.dart';
import 'package:billing_baba/features/dashboard/application/global_search_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GlobalSearchField extends ConsumerStatefulWidget {
  const GlobalSearchField({super.key});

  @override
  ConsumerState<GlobalSearchField> createState() => _GlobalSearchFieldState();
}

class _GlobalSearchFieldState extends ConsumerState<GlobalSearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  final _debouncer = Debouncer();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debouncer.run(() {
      ref.read(globalSearchQueryProvider.notifier).setQuery(value);
      if (value.trim().length >= 2) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              behavior: HitTestBehavior.translucent,
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            targetAnchor: Alignment.bottomLeft,
            offset: const Offset(0, AppSpacing.xs),
            child: Material(
              elevation: 8,
              borderRadius: AppRadius.mdBorder,
              child: SizedBox(
                width: 520,
                child: _SearchResults(onSelected: _removeOverlay),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: _onQueryChanged,
        decoration: InputDecoration(
          hintText: 'Search parties, items, invoices, bills...',
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 20,
          ),
          filled: true,
          fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          border: OutlineInputBorder(
            borderRadius: AppRadius.mdBorder,
            borderSide: BorderSide.none,
          ),
          isDense: true,
        ),
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.onSelected});

  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(globalSearchResultsProvider);

    return resultsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, _) => const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Text('Search failed', style: TextStyle(fontSize: 13)),
      ),
      data: (results) {
        if (results.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Text('No results found', style: TextStyle(fontSize: 13)),
          );
        }

        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320),
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            itemCount: results.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final result = results[index];
              return ListTile(
                dense: true,
                leading: Icon(
                  _iconFor(result.type),
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                title: Text(result.title, style: const TextStyle(fontSize: 13)),
                subtitle: Text(
                  result.subtitle,
                  style: const TextStyle(fontSize: 11),
                ),
                onTap: () {
                  onSelected();
                  _navigate(context, result);
                },
              );
            },
          ),
        );
      },
    );
  }

  IconData _iconFor(GlobalSearchResultType type) => switch (type) {
    GlobalSearchResultType.party => Icons.people_outline,
    GlobalSearchResultType.item => Icons.inventory_2_outlined,
    GlobalSearchResultType.saleInvoice => Icons.receipt_outlined,
    GlobalSearchResultType.purchaseBill => Icons.shopping_cart_outlined,
    GlobalSearchResultType.expense => Icons.payments_outlined,
    GlobalSearchResultType.payment => Icons.account_balance_wallet_outlined,
  };

  void _navigate(BuildContext context, GlobalSearchResult result) {
    switch (result.type) {
      case GlobalSearchResultType.party:
        context.go(AppRoutes.partyDetails);
      case GlobalSearchResultType.item:
        context.go(AppRoutes.items);
      case GlobalSearchResultType.saleInvoice:
        context.go(AppRoutes.saleInvoices);
      case GlobalSearchResultType.purchaseBill:
        context.go(AppRoutes.purchaseBills);
      case GlobalSearchResultType.expense:
        context.go(AppRoutes.purchaseExpenses);
      case GlobalSearchResultType.payment:
        context.go(AppRoutes.salePaymentIn);
    }
  }
}
