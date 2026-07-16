import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_list_header.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InventoryAsyncList<T> extends StatelessWidget {
  const InventoryAsyncList({
    required this.asyncValue,
    required this.items,
    required this.onRefresh,
    required this.itemBuilder,
    this.emptyMessage = 'No items found',
    this.loadingMessage = 'Loading...',
    super.key,
  });

  final AsyncValue<List<T>> asyncValue;
  final List<T> items;
  final Future<void> Function() onRefresh;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String emptyMessage;
  final String loadingMessage;

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      loading: () => RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 120,
              child: Center(
                child: Text(
                  loadingMessage,
                  style: InventoryStyles.emptyStateStyle,
                ),
              ),
            ),
          ],
        ),
      ),
      error: (error, _) {
        final message = InventoryErrorMapper.messageFor(error);
        if (items.isNotEmpty) {
          return Column(
            children: [
              _InventoryErrorBanner(message: message, onRetry: onRefresh),
              Expanded(child: _buildList()),
            ],
          );
        }
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _InventoryErrorBody(message: message, onRetry: onRefresh),
            ],
          ),
        );
      },
      data: (_) => RefreshIndicator(
        onRefresh: onRefresh,
        child: _buildList(),
      ),
    );
  }

  Widget _buildList() {
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 120,
            child: InventoryListEmptyState(message: emptyMessage),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) => itemBuilder(context, items[index]),
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
