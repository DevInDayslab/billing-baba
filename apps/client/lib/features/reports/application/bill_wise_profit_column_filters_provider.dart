import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BillWiseProfitColumnFiltersState {
  const BillWiseProfitColumnFiltersState({
    this.dateColumnFilter,
    this.invoiceNoColumnFilter,
    this.partyNameColumnFilter,
    this.saleAmountColumnFilter,
    this.profitColumnFilter,
  });

  final DateColumnFilter? dateColumnFilter;
  final TextColumnFilter? invoiceNoColumnFilter;
  final TextColumnFilter? partyNameColumnFilter;
  final AmountColumnFilter? saleAmountColumnFilter;
  final AmountColumnFilter? profitColumnFilter;

  bool get hasActiveFilters =>
      (dateColumnFilter?.isActive ?? false) ||
      (invoiceNoColumnFilter?.isActive ?? false) ||
      (partyNameColumnFilter?.isActive ?? false) ||
      (saleAmountColumnFilter?.isActive ?? false) ||
      (profitColumnFilter?.isActive ?? false);

  BillWiseProfitColumnFiltersState copyWith({
    DateColumnFilter? dateColumnFilter,
    bool clearDateColumnFilter = false,
    TextColumnFilter? invoiceNoColumnFilter,
    bool clearInvoiceNoColumnFilter = false,
    TextColumnFilter? partyNameColumnFilter,
    bool clearPartyNameColumnFilter = false,
    AmountColumnFilter? saleAmountColumnFilter,
    bool clearSaleAmountColumnFilter = false,
    AmountColumnFilter? profitColumnFilter,
    bool clearProfitColumnFilter = false,
  }) {
    return BillWiseProfitColumnFiltersState(
      dateColumnFilter: clearDateColumnFilter
          ? null
          : (dateColumnFilter ?? this.dateColumnFilter),
      invoiceNoColumnFilter: clearInvoiceNoColumnFilter
          ? null
          : (invoiceNoColumnFilter ?? this.invoiceNoColumnFilter),
      partyNameColumnFilter: clearPartyNameColumnFilter
          ? null
          : (partyNameColumnFilter ?? this.partyNameColumnFilter),
      saleAmountColumnFilter: clearSaleAmountColumnFilter
          ? null
          : (saleAmountColumnFilter ?? this.saleAmountColumnFilter),
      profitColumnFilter: clearProfitColumnFilter
          ? null
          : (profitColumnFilter ?? this.profitColumnFilter),
    );
  }
}

class BillWiseProfitColumnFilters extends Notifier<BillWiseProfitColumnFiltersState> {
  @override
  BillWiseProfitColumnFiltersState build() =>
      const BillWiseProfitColumnFiltersState();

  void reset() {
    state = const BillWiseProfitColumnFiltersState();
  }

  void setDateColumnFilter(DateColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearDateColumnFilter: true)
        : state.copyWith(dateColumnFilter: filter);
  }

  void setInvoiceNoColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearInvoiceNoColumnFilter: true)
        : state.copyWith(invoiceNoColumnFilter: filter);
  }

  void setPartyNameColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPartyNameColumnFilter: true)
        : state.copyWith(partyNameColumnFilter: filter);
  }

  void setSaleAmountColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearSaleAmountColumnFilter: true)
        : state.copyWith(saleAmountColumnFilter: filter);
  }

  void setProfitColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearProfitColumnFilter: true)
        : state.copyWith(profitColumnFilter: filter);
  }
}

final billWiseProfitColumnFiltersProvider =
    NotifierProvider<BillWiseProfitColumnFilters, BillWiseProfitColumnFiltersState>(
      BillWiseProfitColumnFilters.new,
    );
