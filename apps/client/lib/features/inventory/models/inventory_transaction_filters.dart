import 'package:billing_baba/features/sales/presentation/widgets/sale_column_amount_filter.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_column_date_filter.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_column_select_filter.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_column_text_filter.dart';

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

  final SelectColumnFilter? typeColumnFilter;
  final TextColumnFilter? invoiceRefColumnFilter;
  final TextColumnFilter? partyColumnFilter;
  final DateColumnFilter? dateColumnFilter;
  final AmountColumnFilter? quantityColumnFilter;
  final AmountColumnFilter? priceColumnFilter;
  final SelectColumnFilter? statusColumnFilter;
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
    SelectColumnFilter? typeColumnFilter,
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
    SelectColumnFilter? statusColumnFilter,
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
