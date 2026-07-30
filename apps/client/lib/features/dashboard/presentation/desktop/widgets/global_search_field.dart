import 'dart:async';

import 'package:billing_baba/core/network/offline_utils.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/utils/debouncer.dart';
import 'package:billing_baba/core/widgets/offline_status_banner.dart';
import 'package:billing_baba/features/dashboard/application/global_search_navigation.dart';
import 'package:billing_baba/features/dashboard/application/global_search_provider.dart';
import 'package:billing_baba/features/dashboard/models/global_search_result.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GlobalSearchField extends ConsumerStatefulWidget {
  const GlobalSearchField({super.key});

  @override
  ConsumerState<GlobalSearchField> createState() => _GlobalSearchFieldState();
}

class _GlobalSearchFieldState extends ConsumerState<GlobalSearchField> {
  static const _debounceDuration = Duration(milliseconds: 250);

  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  final _debouncer = Debouncer(duration: _debounceDuration);
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _removeOverlay();
    _debouncer.dispose();
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) return;
    _ensureInventoryLoaded();
    if (_controller.text.trim().isNotEmpty) {
      _showOverlay();
    }
  }

  void _ensureInventoryLoaded() {
    final itemsAsync = ref.read(inventoryItemsProvider);
    if (!itemsAsync.isLoading && (itemsAsync.value ?? []).isEmpty) {
      unawaited(ref.read(inventoryItemsProvider.notifier).refresh());
    }
  }

  void _onQueryChanged(String value) {
    setState(() {});
    _debouncer.run(() {
      if (!mounted) return;

      final trimmed = value.trim();
      ref.read(globalSearchQueryProvider.notifier).setQuery(trimmed);

      if (trimmed.isEmpty) {
        _closeOverlay();
      } else {
        _showOverlay();
      }
    });
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => _GlobalSearchOverlay(
        layerLink: _layerLink,
        onDismiss: _closeOverlay,
        onResultSelected: _onResultSelected,
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _closeOverlay() {
    _removeOverlay();
  }

  void _clearSearch() {
    _debouncer.cancel();
    _controller.clear();
    ref.read(globalSearchQueryProvider.notifier).clear();
    _removeOverlay();
    _focusNode.unfocus();
    setState(() {});
  }

  void _onResultSelected(GlobalSearchResult result) {
    GlobalSearchNavigation.openResult(context, ref, result);
    _clearSearch();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _closeOverlay();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(globalSearchItemResultsProvider, (_, _) {
      _overlayEntry?.markNeedsBuild();
    });
    ref.listen(globalSearchAsyncResultsProvider, (_, _) {
      _overlayEntry?.markNeedsBuild();
    });

    return CompositedTransformTarget(
      link: _layerLink,
      child: Focus(
        onKeyEvent: _onKeyEvent,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onQueryChanged,
          onTap: () {
            _ensureInventoryLoaded();
            if (_controller.text.trim().isNotEmpty) {
              _showOverlay();
            }
          },
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
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    onPressed: _clearSearch,
                    tooltip: 'Clear search',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  )
                : null,
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
      ),
    );
  }
}

class _GlobalSearchOverlay extends ConsumerWidget {
  const _GlobalSearchOverlay({
    required this.layerLink,
    required this.onDismiss,
    required this.onResultSelected,
  });

  final LayerLink layerLink;
  final VoidCallback onDismiss;
  final ValueChanged<GlobalSearchResult> onResultSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(globalSearchQueryProvider);
    final itemResults = ref.watch(globalSearchItemResultsProvider);
    final asyncResults = ref.watch(globalSearchAsyncResultsProvider);
    final remoteResults = asyncResults.asData?.value ?? const [];
    final results = [...remoteResults, ...itemResults];
    final isAsyncLoading = asyncResults.isLoading && !asyncResults.hasValue;
    final isOffline = asyncResults.hasError && isOfflineError(asyncResults.error);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.65;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.translucent,
          ),
        ),
        CompositedTransformFollower(
          link: layerLink,
          targetAnchor: Alignment.bottomLeft,
          offset: const Offset(0, AppSpacing.xs),
          child: Material(
            elevation: 8,
            borderRadius: AppRadius.mdBorder,
            clipBehavior: Clip.antiAlias,
            color: AppColors.surface,
            child: SizedBox(
              width: 520,
              child: _SearchResultsPanel(
                query: query,
                results: results,
                maxHeight: maxHeight,
                isAsyncLoading: isAsyncLoading,
                isOffline: isOffline,
                onResultSelected: onResultSelected,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

typedef _SearchSection = ({
  GlobalSearchResultType type,
  String title,
});

const _searchSections = <_SearchSection>[
  (type: GlobalSearchResultType.party, title: 'Parties'),
  (type: GlobalSearchResultType.item, title: 'Items'),
  (type: GlobalSearchResultType.purchaseBill, title: 'Bills'),
  (type: GlobalSearchResultType.saleInvoice, title: 'Invoices'),
  (type: GlobalSearchResultType.expense, title: 'Expenses'),
  (type: GlobalSearchResultType.payment, title: 'Payments'),
];

class _SearchResultsPanel extends StatelessWidget {
  const _SearchResultsPanel({
    required this.query,
    required this.results,
    required this.maxHeight,
    required this.isAsyncLoading,
    required this.isOffline,
    required this.onResultSelected,
  });

  final String query;
  final List<GlobalSearchResult> results;
  final double maxHeight;
  final bool isAsyncLoading;
  final bool isOffline;
  final ValueChanged<GlobalSearchResult> onResultSelected;

  @override
  Widget build(BuildContext context) {
    if (isOffline && results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Text(
          OfflineMessages.connectToInternet,
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      );
    }

    if (results.isEmpty && isAsyncLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Text(
          'No results found',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      );
    }

    final grouped = <GlobalSearchResultType, List<GlobalSearchResult>>{};
    for (final result in results) {
      grouped.putIfAbsent(result.type, () => []).add(result);
    }

    final slivers = <Widget>[];
    for (final section in _searchSections) {
      final sectionResults = grouped[section.type];
      if (sectionResults == null || sectionResults.isEmpty) continue;

      slivers.add(
        SliverPersistentHeader(
          pinned: true,
          delegate: _SectionHeaderDelegate(title: section.title),
        ),
      );
      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final result = sectionResults[index];
              final isLast = index == sectionResults.length - 1;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SearchResultTile(
                    result: result,
                    query: query,
                    onTap: () => onResultSelected(result),
                  ),
                  if (!isLast)
                    const Divider(
                      height: 1,
                      indent: AppSpacing.lg + 32 + AppSpacing.md,
                    ),
                ],
              );
            },
            childCount: sectionResults.length,
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOffline) const OfflineStatusBanner(),
          Flexible(
            child: CustomScrollView(
              shrinkWrap: true,
              slivers: slivers,
            ),
          ),
          if (isAsyncLoading)
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Searching…',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
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

class _SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SectionHeaderDelegate({required this.title});

  final String title;

  @override
  double get minExtent => 36;

  @override
  double get maxExtent => 36;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SectionHeaderDelegate oldDelegate) {
    return oldDelegate.title != title;
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.result,
    required this.query,
    required this.onTap,
  });

  final GlobalSearchResult result;
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppRadius.smBorder,
                ),
                child: Icon(
                  _iconFor(result.type),
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HighlightedText(
                      text: result.title,
                      query: query,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                    ),
                    if (result.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      _HighlightedText(
                        text: result.subtitle,
                        query: query,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ],
                ),
              ),
              if (result.statusLabel != null) ...[
                const SizedBox(width: AppSpacing.sm),
                _StatusChip(label: result.statusLabel!),
              ],
            ],
          ),
        ),
      ),
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
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (label) {
      'Paid' => (const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
      'Unpaid' => (const Color(0xFFFFEBEE), const Color(0xFFC62828)),
      'Partial' => (const Color(0xFFFFF3E0), const Color(0xFFE65100)),
      'Overdue' => (const Color(0xFFFCE4EC), const Color(0xFFB71C1C)),
      'Cancelled' => (const Color(0xFFF5F5F5), const Color(0xFF9E9E9E)),
      _ => (AppColors.background, AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.query,
    required this.style,
    this.maxLines,
  });

  final String text;
  final String query;
  final TextStyle style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = trimmedQuery.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;

    while (start < text.length) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index < 0) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      final end = index + trimmedQuery.length;
      spans.add(
        TextSpan(
          text: text.substring(index, end),
          style: style.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          ),
        ),
      );
      start = end;
    }

    return RichText(
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(style: style, children: spans),
    );
  }
}
