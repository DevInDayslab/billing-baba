import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart';

enum InventoryTransactionSortColumn {
  type,
  invoiceRef,
  party,
  date,
  quantity,
  pricePerUnit,
  status,
}

enum InventoryTransactionSortDirection {
  none,
  ascending,
  descending,
}

class InventoryTransactionFiltersState {
  const InventoryTransactionFiltersState({
    this.typeColumnFilter,
    this.invoiceRefColumnFilter,
    this.partyColumnFilter,
    this.dateColumnFilter,
    this.quantityColumnFilter,
    this.priceColumnFilter,
    this.statusColumnFilter,
    this.sortColumn = InventoryTransactionSortColumn.date,
    this.sortDirection = InventoryTransactionSortDirection.descending,
    this.currentPage = 0,
  });

  final MultiSelectColumnFilter? typeColumnFilter;
  final TextColumnFilter? invoiceRefColumnFilter;
  final TextColumnFilter? partyColumnFilter;
  final DateColumnFilter? dateColumnFilter;
  final AmountColumnFilter? quantityColumnFilter;
  final AmountColumnFilter? priceColumnFilter;
  final MultiSelectColumnFilter? statusColumnFilter;
  final InventoryTransactionSortColumn sortColumn;
  final InventoryTransactionSortDirection sortDirection;
  final int currentPage;

  bool get hasColumnFilters =>
      typeColumnFilter != null ||
      invoiceRefColumnFilter != null ||
      partyColumnFilter != null ||
      dateColumnFilter != null ||
      quantityColumnFilter != null ||
      priceColumnFilter != null ||
      statusColumnFilter != null;

  InventoryTransactionFiltersState copyWith({
    MultiSelectColumnFilter? typeColumnFilter,
    bool clearTypeColumnFilter = false,
    TextColumnFilter? invoiceRefColumnFilter,
    bool clearInvoiceRefColumnFilter = false,
    TextColumnFilter? partyColumnFilter,
    bool clearPartyColumnFilter = false,
    DateColumnFilter? dateColumnFilter,
    bool clearDateColumnFilter = false,
    AmountColumnFilter? quantityColumnFilter,
    bool clearQuantityColumnFilter = false,
    AmountColumnFilter? priceColumnFilter,
    bool clearPriceColumnFilter = false,
    MultiSelectColumnFilter? statusColumnFilter,
    bool clearStatusColumnFilter = false,
    InventoryTransactionSortColumn? sortColumn,
    InventoryTransactionSortDirection? sortDirection,
    int? currentPage,
  }) {
    return InventoryTransactionFiltersState(
      typeColumnFilter: clearTypeColumnFilter
          ? null
          : (typeColumnFilter ?? this.typeColumnFilter),
      invoiceRefColumnFilter: clearInvoiceRefColumnFilter
          ? null
          : (invoiceRefColumnFilter ?? this.invoiceRefColumnFilter),
      partyColumnFilter: clearPartyColumnFilter
          ? null
          : (partyColumnFilter ?? this.partyColumnFilter),
      dateColumnFilter: clearDateColumnFilter
          ? null
          : (dateColumnFilter ?? this.dateColumnFilter),
      quantityColumnFilter: clearQuantityColumnFilter
          ? null
          : (quantityColumnFilter ?? this.quantityColumnFilter),
      priceColumnFilter: clearPriceColumnFilter
          ? null
          : (priceColumnFilter ?? this.priceColumnFilter),
      statusColumnFilter: clearStatusColumnFilter
          ? null
          : (statusColumnFilter ?? this.statusColumnFilter),
      sortColumn: sortColumn ?? this.sortColumn,
      sortDirection: sortDirection ?? this.sortDirection,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
