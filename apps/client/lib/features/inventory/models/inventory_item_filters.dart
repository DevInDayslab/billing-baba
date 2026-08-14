enum InventoryItemFilterOption {
  active,
  inactive,
  showRawMaterialsOnly,
  hideRawMaterials,
}

/// Options shown in the inventory list filter popover.
const inventoryListFilterOptions = <InventoryItemFilterOption>[
  InventoryItemFilterOption.active,
  InventoryItemFilterOption.inactive,
  InventoryItemFilterOption.showRawMaterialsOnly,
  InventoryItemFilterOption.hideRawMaterials,
];

extension InventoryItemFilterOptionLabel on InventoryItemFilterOption {
  String get label => switch (this) {
    InventoryItemFilterOption.active => 'Active',
    InventoryItemFilterOption.inactive => 'InActive',
    InventoryItemFilterOption.showRawMaterialsOnly => 'Show Raw Materials Only',
    InventoryItemFilterOption.hideRawMaterials => "Don't Show Raw Materials",
  };
}

class InventoryItemFiltersState {
  const InventoryItemFiltersState({
    this.selected = const {},
    this.brandIds = const {},
    this.categoryIds = const {},
  });

  final Set<InventoryItemFilterOption> selected;
  final Set<String> brandIds;
  final Set<String> categoryIds;

  bool get hasActiveFilters =>
      selected.isNotEmpty || brandIds.isNotEmpty || categoryIds.isNotEmpty;

  InventoryItemFiltersState copyWith({
    Set<InventoryItemFilterOption>? selected,
    Set<String>? brandIds,
    Set<String>? categoryIds,
    bool clear = false,
  }) {
    if (clear) return const InventoryItemFiltersState();
    return InventoryItemFiltersState(
      selected: selected ?? this.selected,
      brandIds: brandIds ?? this.brandIds,
      categoryIds: categoryIds ?? this.categoryIds,
    );
  }
}
