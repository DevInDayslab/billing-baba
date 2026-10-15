import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SalePurchaseByPartyColumnFiltersState {
  const SalePurchaseByPartyColumnFiltersState({
    this.partyNameColumnFilter,
    this.saleAmountColumnFilter,
    this.purchaseAmountColumnFilter,
    this.receivableColumnFilter,
    this.payableColumnFilter,
  });

  final TextColumnFilter? partyNameColumnFilter;
  final AmountColumnFilter? saleAmountColumnFilter;
  final AmountColumnFilter? purchaseAmountColumnFilter;
  final AmountColumnFilter? receivableColumnFilter;
  final AmountColumnFilter? payableColumnFilter;

  bool get hasActiveFilters =>
      (partyNameColumnFilter?.isActive ?? false) ||
      (saleAmountColumnFilter?.isActive ?? false) ||
      (purchaseAmountColumnFilter?.isActive ?? false) ||
      (receivableColumnFilter?.isActive ?? false) ||
      (payableColumnFilter?.isActive ?? false);

  SalePurchaseByPartyColumnFiltersState copyWith({
    TextColumnFilter? partyNameColumnFilter,
    bool clearPartyNameColumnFilter = false,
    AmountColumnFilter? saleAmountColumnFilter,
    bool clearSaleAmountColumnFilter = false,
    AmountColumnFilter? purchaseAmountColumnFilter,
    bool clearPurchaseAmountColumnFilter = false,
    AmountColumnFilter? receivableColumnFilter,
    bool clearReceivableColumnFilter = false,
    AmountColumnFilter? payableColumnFilter,
    bool clearPayableColumnFilter = false,
  }) {
    return SalePurchaseByPartyColumnFiltersState(
      partyNameColumnFilter: clearPartyNameColumnFilter
          ? null
          : (partyNameColumnFilter ?? this.partyNameColumnFilter),
      saleAmountColumnFilter: clearSaleAmountColumnFilter
          ? null
          : (saleAmountColumnFilter ?? this.saleAmountColumnFilter),
      purchaseAmountColumnFilter: clearPurchaseAmountColumnFilter
          ? null
          : (purchaseAmountColumnFilter ?? this.purchaseAmountColumnFilter),
      receivableColumnFilter: clearReceivableColumnFilter
          ? null
          : (receivableColumnFilter ?? this.receivableColumnFilter),
      payableColumnFilter: clearPayableColumnFilter
          ? null
          : (payableColumnFilter ?? this.payableColumnFilter),
    );
  }
}

class SalePurchaseByPartyColumnFilters
    extends Notifier<SalePurchaseByPartyColumnFiltersState> {
  @override
  SalePurchaseByPartyColumnFiltersState build() =>
      const SalePurchaseByPartyColumnFiltersState();

  void reset() {
    state = const SalePurchaseByPartyColumnFiltersState();
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

  void setReceivableColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearReceivableColumnFilter: true)
        : state.copyWith(receivableColumnFilter: filter);
  }

  void setPayableColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPayableColumnFilter: true)
        : state.copyWith(payableColumnFilter: filter);
  }
}

final salePurchaseByPartyColumnFiltersProvider =
    NotifierProvider<
      SalePurchaseByPartyColumnFilters,
      SalePurchaseByPartyColumnFiltersState
    >(SalePurchaseByPartyColumnFilters.new);
