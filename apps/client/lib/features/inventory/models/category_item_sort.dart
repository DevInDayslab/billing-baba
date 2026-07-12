enum CategoryItemSortColumn {
  name,
  quantity,
  stockValue,
}

enum CategoryItemSortDirection {
  none,
  ascending,
  descending,
}

class CategoryItemSortState {
  const CategoryItemSortState({
    this.column = CategoryItemSortColumn.name,
    this.direction = CategoryItemSortDirection.none,
  });

  final CategoryItemSortColumn column;
  final CategoryItemSortDirection direction;

  CategoryItemSortState copyWith({
    CategoryItemSortColumn? column,
    CategoryItemSortDirection? direction,
  }) {
    return CategoryItemSortState(
      column: column ?? this.column,
      direction: direction ?? this.direction,
    );
  }
}
