import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Paginated slice of the local inventory catalog.
class PaginatedInventoryItems {
  const PaginatedInventoryItems({
    required this.items,
    required this.totalCount,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<InventoryItem> items;
  final int totalCount;
  final bool hasMore;
  final bool isLoadingMore;

  PaginatedInventoryItems copyWith({
    List<InventoryItem>? items,
    int? totalCount,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PaginatedInventoryItems(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

extension InventoryItemsPageAsync on AsyncValue<PaginatedInventoryItems> {
  AsyncValue<List<InventoryItem>> get itemsOnly => switch (this) {
    AsyncData(:final value) => AsyncData(value.items),
    AsyncLoading() => const AsyncLoading<List<InventoryItem>>(),
    AsyncError(:final error, :final stackTrace) =>
      AsyncError<List<InventoryItem>>(error, stackTrace),
  };
}

class InventoryItemsQuery {
  const InventoryItemsQuery({
    this.searchQuery,
    this.type,
    this.categoryId,
  });

  final String? searchQuery;
  final ItemType? type;
  final String? categoryId;
}
