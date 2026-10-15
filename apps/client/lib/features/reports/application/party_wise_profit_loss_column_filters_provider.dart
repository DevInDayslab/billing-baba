import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PartyWiseProfitLossColumnFiltersState {
  const PartyWiseProfitLossColumnFiltersState({
    this.partyNameColumnFilter,
    this.phoneColumnFilter,
    this.saleAmountColumnFilter,
    this.purchaseAmountColumnFilter,
    this.profitColumnFilter,
  });

  final TextColumnFilter? partyNameColumnFilter;
  final TextColumnFilter? phoneColumnFilter;
  final AmountColumnFilter? saleAmountColumnFilter;
  final AmountColumnFilter? purchaseAmountColumnFilter;
  final AmountColumnFilter? profitColumnFilter;

  bool get hasActiveFilters =>
      (partyNameColumnFilter?.isActive ?? false) ||
      (phoneColumnFilter?.isActive ?? false) ||
      (saleAmountColumnFilter?.isActive ?? false) ||
      (purchaseAmountColumnFilter?.isActive ?? false) ||
      (profitColumnFilter?.isActive ?? false);

  PartyWiseProfitLossColumnFiltersState copyWith({
    TextColumnFilter? partyNameColumnFilter,
    bool clearPartyNameColumnFilter = false,
    TextColumnFilter? phoneColumnFilter,
    bool clearPhoneColumnFilter = false,
    AmountColumnFilter? saleAmountColumnFilter,
    bool clearSaleAmountColumnFilter = false,
    AmountColumnFilter? purchaseAmountColumnFilter,
    bool clearPurchaseAmountColumnFilter = false,
    AmountColumnFilter? profitColumnFilter,
    bool clearProfitColumnFilter = false,
  }) {
    return PartyWiseProfitLossColumnFiltersState(
      partyNameColumnFilter: clearPartyNameColumnFilter
          ? null
          : (partyNameColumnFilter ?? this.partyNameColumnFilter),
      phoneColumnFilter: clearPhoneColumnFilter
          ? null
          : (phoneColumnFilter ?? this.phoneColumnFilter),
      saleAmountColumnFilter: clearSaleAmountColumnFilter
          ? null
          : (saleAmountColumnFilter ?? this.saleAmountColumnFilter),
      purchaseAmountColumnFilter: clearPurchaseAmountColumnFilter
          ? null
          : (purchaseAmountColumnFilter ?? this.purchaseAmountColumnFilter),
      profitColumnFilter: clearProfitColumnFilter
          ? null
          : (profitColumnFilter ?? this.profitColumnFilter),
    );
  }
}

class PartyWiseProfitLossColumnFilters
    extends Notifier<PartyWiseProfitLossColumnFiltersState> {
  @override
  PartyWiseProfitLossColumnFiltersState build() =>
      const PartyWiseProfitLossColumnFiltersState();

  void reset() {
    state = const PartyWiseProfitLossColumnFiltersState();
  }

  void setPartyNameColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPartyNameColumnFilter: true)
        : state.copyWith(partyNameColumnFilter: filter);
  }

  void setPhoneColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPhoneColumnFilter: true)
        : state.copyWith(phoneColumnFilter: filter);
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

  void setProfitColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearProfitColumnFilter: true)
        : state.copyWith(profitColumnFilter: filter);
  }
}

final partyWiseProfitLossColumnFiltersProvider =
    NotifierProvider<
      PartyWiseProfitLossColumnFilters,
      PartyWiseProfitLossColumnFiltersState
    >(PartyWiseProfitLossColumnFilters.new);
