import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/shared/image/app_image_prefetcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InventoryAsyncList<T> extends ConsumerStatefulWidget {
  const InventoryAsyncList({
    required this.asyncValue,
    required this.items,
    required this.onRefresh,
    required this.itemBuilder,
    this.showCachedWhileLoading = false,
    this.emptyMessage = 'No items found',
    this.loadingMessage = 'Loading...',
    this.imageUrlExtractor,
    this.onPrefetchItems,
    this.prefetchLookahead = 30,
    this.estimatedItemExtent = 56,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
    super.key,
  });

  final AsyncValue<List<T>> asyncValue;
  final List<T> items;
  final Future<void> Function() onRefresh;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final String emptyMessage;
  final String loadingMessage;
  final bool showCachedWhileLoading;
  final String? Function(T item)? imageUrlExtractor;
  final void Function(List<T> items)? onPrefetchItems;
  final int prefetchLookahead;
  final double estimatedItemExtent;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;

  @override
  ConsumerState<InventoryAsyncList<T>> createState() =>
      _InventoryAsyncListState<T>();
}

class _InventoryAsyncListState<T> extends ConsumerState<InventoryAsyncList<T>> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_prefetchAhead);
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefetchAhead());
  }

  @override
  void didUpdateWidget(covariant InventoryAsyncList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _prefetchAhead());
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_prefetchAhead)
      ..dispose();
    super.dispose();
  }

  void _prefetchAhead() {
    if (widget.items.isEmpty) return;

    if (widget.hasMore &&
        !widget.isLoadingMore &&
        widget.onLoadMore != null &&
        _scrollController.position.extentAfter < widget.estimatedItemExtent * 4) {
      widget.onLoadMore!();
    }

    final firstVisible = AppImagePrefetcher.estimateFirstVisibleIndex(
      _scrollController,
      itemExtent: widget.estimatedItemExtent,
    );
    final lastVisible = AppImagePrefetcher.estimateLastVisibleIndex(
      _scrollController,
      itemExtent: widget.estimatedItemExtent,
    ).clamp(0, widget.items.length - 1);

    final extractor = widget.imageUrlExtractor;
    if (extractor != null) {
      ref.read(appImagePrefetcherProvider).prefetchItemsWindow(
            items: widget.items,
            firstVisibleIndex: firstVisible,
            lastVisibleIndex: lastVisible,
            urlExtractor: extractor,
            lookahead: widget.prefetchLookahead,
          );
    }

    widget.onPrefetchItems?.call(
      widget.items.sublist(
        firstVisible.clamp(0, widget.items.length - 1),
        (lastVisible + widget.prefetchLookahead + 1).clamp(0, widget.items.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.asyncValue.when(
      loading: () {
        if (widget.showCachedWhileLoading && widget.items.isNotEmpty) {
          return RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: _buildList(),
          );
        }
        return RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: 120,
                child: Center(
                  child: Text(
                    widget.loadingMessage,
                    style: InventoryStyles.emptyStateStyle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      error: (error, _) {
        final message = InventoryErrorMapper.messageFor(error);
        if (widget.items.isNotEmpty) {
          return Column(
            children: [
              _InventoryErrorBanner(message: message, onRetry: widget.onRefresh),
              Expanded(child: _buildList()),
            ],
          );
        }
        return RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _InventoryErrorBody(message: message, onRetry: widget.onRefresh),
            ],
          ),
        );
      },
      data: (_) => RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: _buildList(),
      ),
    );
  }

  Widget _buildList() {
    if (widget.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 120,
            child: InventoryListEmptyState(message: widget.emptyMessage),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: widget.items.length + (widget.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        return widget.itemBuilder(context, widget.items[index], index);
      },
    );
  }
}

class _InventoryErrorBanner extends StatelessWidget {
  const _InventoryErrorBanner({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFEBEE),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 12,
                  color: inventoryNegativeColor,
                ),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryErrorBody extends StatelessWidget {
  const _InventoryErrorBody({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: inventoryNegativeColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
