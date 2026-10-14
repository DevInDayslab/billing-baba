import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PurchaseReportColumnFiltersState {
  const PurchaseReportColumnFiltersState({
    this.dateColumnFilter,
    this.invoiceNoColumnFilter,
    this.partyNameColumnFilter,
    this.paymentTypeColumnFilter,
    this.statusColumnFilter,
    this.amountColumnFilter,
    this.balanceColumnFilter,
  });

  final DateColumnFilter? dateColumnFilter;
  final TextColumnFilter? invoiceNoColumnFilter;
  final TextColumnFilter? partyNameColumnFilter;
  final SelectColumnFilter? paymentTypeColumnFilter;
  final SelectColumnFilter? statusColumnFilter;
  final AmountColumnFilter? amountColumnFilter;
  final AmountColumnFilter? balanceColumnFilter;

  bool get hasActiveFilters =>
      (dateColumnFilter?.isActive ?? false) ||
      (invoiceNoColumnFilter?.isActive ?? false) ||
      (partyNameColumnFilter?.isActive ?? false) ||
      (paymentTypeColumnFilter?.isActive ?? false) ||
      (statusColumnFilter?.isActive ?? false) ||
      (amountColumnFilter?.isActive ?? false) ||
      (balanceColumnFilter?.isActive ?? false);

  PurchaseReportColumnFiltersState copyWith({
    DateColumnFilter? dateColumnFilter,
    bool clearDateColumnFilter = false,
    TextColumnFilter? invoiceNoColumnFilter,
    bool clearInvoiceNoColumnFilter = false,
    TextColumnFilter? partyNameColumnFilter,
    bool clearPartyNameColumnFilter = false,
    SelectColumnFilter? paymentTypeColumnFilter,
    bool clearPaymentTypeColumnFilter = false,
    SelectColumnFilter? statusColumnFilter,
    bool clearStatusColumnFilter = false,
    AmountColumnFilter? amountColumnFilter,
    bool clearAmountColumnFilter = false,
    AmountColumnFilter? balanceColumnFilter,
    bool clearBalanceColumnFilter = false,
  }) {
    return PurchaseReportColumnFiltersState(
      dateColumnFilter: clearDateColumnFilter
          ? null
          : (dateColumnFilter ?? this.dateColumnFilter),
      invoiceNoColumnFilter: clearInvoiceNoColumnFilter
          ? null
          : (invoiceNoColumnFilter ?? this.invoiceNoColumnFilter),
      partyNameColumnFilter: clearPartyNameColumnFilter
          ? null
          : (partyNameColumnFilter ?? this.partyNameColumnFilter),
      paymentTypeColumnFilter: clearPaymentTypeColumnFilter
          ? null
          : (paymentTypeColumnFilter ?? this.paymentTypeColumnFilter),
      statusColumnFilter: clearStatusColumnFilter
          ? null
          : (statusColumnFilter ?? this.statusColumnFilter),
      amountColumnFilter: clearAmountColumnFilter
          ? null
          : (amountColumnFilter ?? this.amountColumnFilter),
      balanceColumnFilter: clearBalanceColumnFilter
          ? null
          : (balanceColumnFilter ?? this.balanceColumnFilter),
    );
  }
}

class PurchaseReportColumnFilters
    extends Notifier<PurchaseReportColumnFiltersState> {
  @override
  PurchaseReportColumnFiltersState build() =>
      const PurchaseReportColumnFiltersState();

  void reset() {
    state = const PurchaseReportColumnFiltersState();
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

  void setPaymentTypeColumnFilter(SelectColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearPaymentTypeColumnFilter: true)
        : state.copyWith(paymentTypeColumnFilter: filter);
  }

  void setStatusColumnFilter(SelectColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearStatusColumnFilter: true)
        : state.copyWith(statusColumnFilter: filter);
  }

  void setAmountColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearAmountColumnFilter: true)
        : state.copyWith(amountColumnFilter: filter);
  }

  void setBalanceColumnFilter(AmountColumnFilter? filter) {
    state = filter == null
        ? state.copyWith(clearBalanceColumnFilter: true)
        : state.copyWith(balanceColumnFilter: filter);
  }
}

final purchaseReportColumnFiltersProvider = NotifierProvider<
    PurchaseReportColumnFilters,
    PurchaseReportColumnFiltersState>(PurchaseReportColumnFilters.new);
