import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SalePurchaseByPartyGroupColumnFiltersState {
  const SalePurchaseByPartyGroupColumnFiltersState({
    this.partyGroupColumnFilter,
    this.partyNameColumnFilter,
    this.saleAmountColumnFilter,
    this.purchaseAmountColumnFilter,
  });

  final TextColumnFilter? partyGroupColumnFilter;
  final TextColumnFilter? partyNameColumnFilter;
  final AmountColumnFilter? saleAmountColumnFilter;
  final AmountColumnFilter? purchaseAmountColumnFilter;

  bool get hasActiveFilters =>
      (partyGroupColumnFilter?.isActive ?? false) ||
      (partyNameColumnFilter?.isActive ?? false) ||
      (saleAmountColumnFilter?.isActive ?? false) ||
      (purchaseAmountColumnFilter?.isActive ?? false);

  SalePurchaseByPartyGroupColumnFiltersState copyWith({
    TextColumnFilter? partyGroupColumnFilter,
    bool clearPartyGroupColumnFilter = false,
    TextColumnFilter? partyNameColumnFilter,
    bool clearPartyNameColumnFilter = false,
    AmountColumnFilter? saleAmountColumnFilter,
    bool clearSaleAmountColumnFilter = false,
    AmountColumnFilter? purchaseAmountColumnFilter,
    bool clearPurchaseAmountColumnFilter = false,
  }) {
    return SalePurchaseByPartyGroupColumnFiltersState(
      partyGroupColumnFilter: clearPartyGroupColumnFilter
          ? null
          : (partyGroupColumnFilter ?? this.partyGroupColumnFilter),
      partyNameColumnFilter: clearPartyNameColumnFilter
          ? null
          : (partyNameColumnFilter ?? this.partyNameColumnFilter),
      saleAmountColumnFilter: clearSaleAmountColumnFilter
          ? null
          : (saleAmountColumnFilter ?? this.saleAmountColumnFilter),
      purchaseAmountColumnFilter: clearPurchaseAmountColumnFilter
          ? null
          : (purchaseAmountColumnFilter ?? this.purchaseAmountColumnFilter),
    );
  }
}

class SalePurchaseByPartyGroupColumnFilters
    extends Notifier<SalePurchaseByPartyGroupColumnFiltersState> {
  @override
  SalePurchaseByPartyGroupColumnFiltersState build() =>
      const SalePurchaseByPartyGroupColumnFiltersState();

  void reset() {
    state = const SalePurchaseByPartyGroupColumnFiltersState();
  }

  void setPartyGroupColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPartyGroupColumnFilter: true)
        : state.copyWith(partyGroupColumnFilter: filter);
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

  void setPurchaseAmountColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPurchaseAmountColumnFilter: true)
        : state.copyWith(purchaseAmountColumnFilter: filter);
  }
}

final salePurchaseByPartyGroupColumnFiltersProvider =
    NotifierProvider<
      SalePurchaseByPartyGroupColumnFilters,
      SalePurchaseByPartyGroupColumnFiltersState
    >(SalePurchaseByPartyGroupColumnFilters.new);
