import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllPartiesColumnFiltersState {
  const AllPartiesColumnFiltersState({
    this.partyNameColumnFilter,
    this.emailColumnFilter,
    this.phoneColumnFilter,
    this.receivableColumnFilter,
    this.payableColumnFilter,
    this.creditLimitColumnFilter,
  });

  final TextColumnFilter? partyNameColumnFilter;
  final TextColumnFilter? emailColumnFilter;
  final TextColumnFilter? phoneColumnFilter;
  final AmountColumnFilter? receivableColumnFilter;
  final AmountColumnFilter? payableColumnFilter;
  final AmountColumnFilter? creditLimitColumnFilter;

  bool get hasActiveFilters =>
      (partyNameColumnFilter?.isActive ?? false) ||
      (emailColumnFilter?.isActive ?? false) ||
      (phoneColumnFilter?.isActive ?? false) ||
      (receivableColumnFilter?.isActive ?? false) ||
      (payableColumnFilter?.isActive ?? false) ||
      (creditLimitColumnFilter?.isActive ?? false);

  AllPartiesColumnFiltersState copyWith({
    TextColumnFilter? partyNameColumnFilter,
    bool clearPartyNameColumnFilter = false,
    TextColumnFilter? emailColumnFilter,
    bool clearEmailColumnFilter = false,
    TextColumnFilter? phoneColumnFilter,
    bool clearPhoneColumnFilter = false,
    AmountColumnFilter? receivableColumnFilter,
    bool clearReceivableColumnFilter = false,
    AmountColumnFilter? payableColumnFilter,
    bool clearPayableColumnFilter = false,
    AmountColumnFilter? creditLimitColumnFilter,
    bool clearCreditLimitColumnFilter = false,
  }) {
    return AllPartiesColumnFiltersState(
      partyNameColumnFilter: clearPartyNameColumnFilter
          ? null
          : (partyNameColumnFilter ?? this.partyNameColumnFilter),
      emailColumnFilter: clearEmailColumnFilter
          ? null
          : (emailColumnFilter ?? this.emailColumnFilter),
      phoneColumnFilter: clearPhoneColumnFilter
          ? null
          : (phoneColumnFilter ?? this.phoneColumnFilter),
      receivableColumnFilter: clearReceivableColumnFilter
          ? null
          : (receivableColumnFilter ?? this.receivableColumnFilter),
      payableColumnFilter: clearPayableColumnFilter
          ? null
          : (payableColumnFilter ?? this.payableColumnFilter),
      creditLimitColumnFilter: clearCreditLimitColumnFilter
          ? null
          : (creditLimitColumnFilter ?? this.creditLimitColumnFilter),
    );
  }
}

class AllPartiesColumnFilters extends Notifier<AllPartiesColumnFiltersState> {
  @override
  AllPartiesColumnFiltersState build() => const AllPartiesColumnFiltersState();

  void reset() {
    state = const AllPartiesColumnFiltersState();
  }

  void setPartyNameColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPartyNameColumnFilter: true)
        : state.copyWith(partyNameColumnFilter: filter);
  }

  void setEmailColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearEmailColumnFilter: true)
        : state.copyWith(emailColumnFilter: filter);
  }

  void setPhoneColumnFilter(TextColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPhoneColumnFilter: true)
        : state.copyWith(phoneColumnFilter: filter);
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

  void setCreditLimitColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearCreditLimitColumnFilter: true)
        : state.copyWith(creditLimitColumnFilter: filter);
  }
}

final allPartiesColumnFiltersProvider =
    NotifierProvider<AllPartiesColumnFilters, AllPartiesColumnFiltersState>(
      AllPartiesColumnFilters.new,
    );
