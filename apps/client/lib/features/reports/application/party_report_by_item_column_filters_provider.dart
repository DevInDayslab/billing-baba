import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PartyReportByItemColumnFiltersState {
  const PartyReportByItemColumnFiltersState({
    this.partyNameColumnFilter,
    this.saleQuantityColumnFilter,
    this.saleAmountColumnFilter,
    this.purchaseQuantityColumnFilter,
    this.purchaseAmountColumnFilter,
  });

  final TextColumnFilter? partyNameColumnFilter;
  final AmountColumnFilter? saleQuantityColumnFilter;
  final AmountColumnFilter? saleAmountColumnFilter;
  final AmountColumnFilter? purchaseQuantityColumnFilter;
  final AmountColumnFilter? purchaseAmountColumnFilter;

  bool get hasActiveFilters =>
      (partyNameColumnFilter?.isActive ?? false) ||
      (saleQuantityColumnFilter?.isActive ?? false) ||
      (saleAmountColumnFilter?.isActive ?? false) ||
      (purchaseQuantityColumnFilter?.isActive ?? false) ||
      (purchaseAmountColumnFilter?.isActive ?? false);

  PartyReportByItemColumnFiltersState copyWith({
    TextColumnFilter? partyNameColumnFilter,
    bool clearPartyNameColumnFilter = false,
    AmountColumnFilter? saleQuantityColumnFilter,
    bool clearSaleQuantityColumnFilter = false,
    AmountColumnFilter? saleAmountColumnFilter,
    bool clearSaleAmountColumnFilter = false,
    AmountColumnFilter? purchaseQuantityColumnFilter,
    bool clearPurchaseQuantityColumnFilter = false,
    AmountColumnFilter? purchaseAmountColumnFilter,
    bool clearPurchaseAmountColumnFilter = false,
  }) {
    return PartyReportByItemColumnFiltersState(
      partyNameColumnFilter: clearPartyNameColumnFilter
          ? null
          : (partyNameColumnFilter ?? this.partyNameColumnFilter),
      saleQuantityColumnFilter: clearSaleQuantityColumnFilter
          ? null
          : (saleQuantityColumnFilter ?? this.saleQuantityColumnFilter),
      saleAmountColumnFilter: clearSaleAmountColumnFilter
          ? null
          : (saleAmountColumnFilter ?? this.saleAmountColumnFilter),
      purchaseQuantityColumnFilter: clearPurchaseQuantityColumnFilter
          ? null
          : (purchaseQuantityColumnFilter ??
                this.purchaseQuantityColumnFilter),
      purchaseAmountColumnFilter: clearPurchaseAmountColumnFilter
          ? null
          : (purchaseAmountColumnFilter ?? this.purchaseAmountColumnFilter),
    );
  }
}

class PartyReportByItemColumnFilters
    extends Notifier<PartyReportByItemColumnFiltersState> {
  @override
  PartyReportByItemColumnFiltersState build() =>
      const PartyReportByItemColumnFiltersState();

  void reset() {
    state = const PartyReportByItemColumnFiltersState();
  }

  void setPartyNameColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPartyNameColumnFilter: true)
        : state.copyWith(partyNameColumnFilter: filter);
  }

  void setSaleQuantityColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearSaleQuantityColumnFilter: true)
        : state.copyWith(saleQuantityColumnFilter: filter);
  }

  void setSaleAmountColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearSaleAmountColumnFilter: true)
        : state.copyWith(saleAmountColumnFilter: filter);
  }

  void setPurchaseQuantityColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPurchaseQuantityColumnFilter: true)
        : state.copyWith(purchaseQuantityColumnFilter: filter);
  }

  void setPurchaseAmountColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPurchaseAmountColumnFilter: true)
        : state.copyWith(purchaseAmountColumnFilter: filter);
  }
}

final partyReportByItemColumnFiltersProvider =
    NotifierProvider<
      PartyReportByItemColumnFilters,
      PartyReportByItemColumnFiltersState
    >(PartyReportByItemColumnFilters.new);
