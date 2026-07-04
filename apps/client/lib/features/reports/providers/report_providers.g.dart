// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BillWiseProfitReport)
final billWiseProfitReportProvider = BillWiseProfitReportProvider._();

final class BillWiseProfitReportProvider
    extends
        $AsyncNotifierProvider<BillWiseProfitReport, BillWiseProfitReportData> {
  BillWiseProfitReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billWiseProfitReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billWiseProfitReportHash();

  @$internal
  @override
  BillWiseProfitReport create() => BillWiseProfitReport();
}

String _$billWiseProfitReportHash() =>
    r'30d55ecb1df74e84ad327c53442e0364dc477635';

abstract class _$BillWiseProfitReport
    extends $AsyncNotifier<BillWiseProfitReportData> {
  FutureOr<BillWiseProfitReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<BillWiseProfitReportData>,
              BillWiseProfitReportData
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<BillWiseProfitReportData>,
                BillWiseProfitReportData
              >,
              AsyncValue<BillWiseProfitReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(CashFlowReport)
final cashFlowReportProvider = CashFlowReportProvider._();

final class CashFlowReportProvider
    extends $AsyncNotifierProvider<CashFlowReport, CashFlowReportData> {
  CashFlowReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cashFlowReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cashFlowReportHash();

  @$internal
  @override
  CashFlowReport create() => CashFlowReport();
}

String _$cashFlowReportHash() => r'5ebf72cb55622fd37cd0d93aa2d082a73ed4ff6d';

abstract class _$CashFlowReport extends $AsyncNotifier<CashFlowReportData> {
  FutureOr<CashFlowReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CashFlowReportData>, CashFlowReportData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CashFlowReportData>, CashFlowReportData>,
              AsyncValue<CashFlowReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(PartyWiseProfitLossReport)
final partyWiseProfitLossReportProvider = PartyWiseProfitLossReportProvider._();

final class PartyWiseProfitLossReportProvider
    extends
        $AsyncNotifierProvider<
          PartyWiseProfitLossReport,
          PartyWiseProfitLossReportData
        > {
  PartyWiseProfitLossReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partyWiseProfitLossReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partyWiseProfitLossReportHash();

  @$internal
  @override
  PartyWiseProfitLossReport create() => PartyWiseProfitLossReport();
}

String _$partyWiseProfitLossReportHash() =>
    r'd18df4a7ea3a3d01f4cbbee288ef1e8946f3926e';

abstract class _$PartyWiseProfitLossReport
    extends $AsyncNotifier<PartyWiseProfitLossReportData> {
  FutureOr<PartyWiseProfitLossReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PartyWiseProfitLossReportData>,
              PartyWiseProfitLossReportData
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PartyWiseProfitLossReportData>,
                PartyWiseProfitLossReportData
              >,
              AsyncValue<PartyWiseProfitLossReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(PartyReportByItemReport)
final partyReportByItemReportProvider = PartyReportByItemReportProvider._();

final class PartyReportByItemReportProvider
    extends
        $AsyncNotifierProvider<
          PartyReportByItemReport,
          PartyReportByItemReportData?
        > {
  PartyReportByItemReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partyReportByItemReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partyReportByItemReportHash();

  @$internal
  @override
  PartyReportByItemReport create() => PartyReportByItemReport();
}

String _$partyReportByItemReportHash() =>
    r'59e4941cf3edcb1c067166370d745bd7fad26ae8';

abstract class _$PartyReportByItemReport
    extends $AsyncNotifier<PartyReportByItemReportData?> {
  FutureOr<PartyReportByItemReportData?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PartyReportByItemReportData?>,
              PartyReportByItemReportData?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PartyReportByItemReportData?>,
                PartyReportByItemReportData?
              >,
              AsyncValue<PartyReportByItemReportData?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SalePurchaseByPartyReport)
final salePurchaseByPartyReportProvider = SalePurchaseByPartyReportProvider._();

final class SalePurchaseByPartyReportProvider
    extends
        $AsyncNotifierProvider<
          SalePurchaseByPartyReport,
          SalePurchaseByPartyReportData
        > {
  SalePurchaseByPartyReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'salePurchaseByPartyReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$salePurchaseByPartyReportHash();

  @$internal
  @override
  SalePurchaseByPartyReport create() => SalePurchaseByPartyReport();
}

String _$salePurchaseByPartyReportHash() =>
    r'85983f5866b3a941750573397782151b55e41dc5';

abstract class _$SalePurchaseByPartyReport
    extends $AsyncNotifier<SalePurchaseByPartyReportData> {
  FutureOr<SalePurchaseByPartyReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<SalePurchaseByPartyReportData>,
              SalePurchaseByPartyReportData
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<SalePurchaseByPartyReportData>,
                SalePurchaseByPartyReportData
              >,
              AsyncValue<SalePurchaseByPartyReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SalePurchaseByPartyGroupReport)
final salePurchaseByPartyGroupReportProvider =
    SalePurchaseByPartyGroupReportProvider._();

final class SalePurchaseByPartyGroupReportProvider
    extends
        $AsyncNotifierProvider<
          SalePurchaseByPartyGroupReport,
          SalePurchaseByPartyGroupReportData
        > {
  SalePurchaseByPartyGroupReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'salePurchaseByPartyGroupReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$salePurchaseByPartyGroupReportHash();

  @$internal
  @override
  SalePurchaseByPartyGroupReport create() => SalePurchaseByPartyGroupReport();
}

String _$salePurchaseByPartyGroupReportHash() =>
    r'a665d025dc8e74c07c0142c40f538540520ccc9c';

abstract class _$SalePurchaseByPartyGroupReport
    extends $AsyncNotifier<SalePurchaseByPartyGroupReportData> {
  FutureOr<SalePurchaseByPartyGroupReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<SalePurchaseByPartyGroupReportData>,
              SalePurchaseByPartyGroupReportData
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<SalePurchaseByPartyGroupReportData>,
                SalePurchaseByPartyGroupReportData
              >,
              AsyncValue<SalePurchaseByPartyGroupReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(Gstr9Report)
final gstr9ReportProvider = Gstr9ReportProvider._();

final class Gstr9ReportProvider
    extends $AsyncNotifierProvider<Gstr9Report, Gstr9ReportData> {
  Gstr9ReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gstr9ReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gstr9ReportHash();

  @$internal
  @override
  Gstr9Report create() => Gstr9Report();
}

String _$gstr9ReportHash() => r'500ab0cab2685d71ae96c456dba6ae93db2a6369';

abstract class _$Gstr9Report extends $AsyncNotifier<Gstr9ReportData> {
  FutureOr<Gstr9ReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Gstr9ReportData>, Gstr9ReportData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Gstr9ReportData>, Gstr9ReportData>,
              AsyncValue<Gstr9ReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SaleSummaryByHsnReport)
final saleSummaryByHsnReportProvider = SaleSummaryByHsnReportProvider._();

final class SaleSummaryByHsnReportProvider
    extends
        $AsyncNotifierProvider<
          SaleSummaryByHsnReport,
          SaleSummaryByHsnReportData
        > {
  SaleSummaryByHsnReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleSummaryByHsnReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleSummaryByHsnReportHash();

  @$internal
  @override
  SaleSummaryByHsnReport create() => SaleSummaryByHsnReport();
}

String _$saleSummaryByHsnReportHash() =>
    r'bfa0ef06572207dd61a3fb4edfb380ece2ba7c1f';

abstract class _$SaleSummaryByHsnReport
    extends $AsyncNotifier<SaleSummaryByHsnReportData> {
  FutureOr<SaleSummaryByHsnReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<SaleSummaryByHsnReportData>,
              SaleSummaryByHsnReportData
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<SaleSummaryByHsnReportData>,
                SaleSummaryByHsnReportData
              >,
              AsyncValue<SaleSummaryByHsnReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SacReportReport)
final sacReportReportProvider = SacReportReportProvider._();

final class SacReportReportProvider
    extends $AsyncNotifierProvider<SacReportReport, SacReportData> {
  SacReportReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sacReportReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sacReportReportHash();

  @$internal
  @override
  SacReportReport create() => SacReportReport();
}

String _$sacReportReportHash() => r'e1f797dcd1185f07072a610f4db6d0f7457b2d8e';

abstract class _$SacReportReport extends $AsyncNotifier<SacReportData> {
  FutureOr<SacReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SacReportData>, SacReportData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SacReportData>, SacReportData>,
              AsyncValue<SacReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ItemReportByPartyReport)
final itemReportByPartyReportProvider = ItemReportByPartyReportProvider._();

final class ItemReportByPartyReportProvider
    extends
        $AsyncNotifierProvider<
          ItemReportByPartyReport,
          ItemReportByPartyReportData
        > {
  ItemReportByPartyReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemReportByPartyReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemReportByPartyReportHash();

  @$internal
  @override
  ItemReportByPartyReport create() => ItemReportByPartyReport();
}

String _$itemReportByPartyReportHash() =>
    r'6b7c76dc5b5fb0fc85ec93d4414c8640cfc6bbfa';

abstract class _$ItemReportByPartyReport
    extends $AsyncNotifier<ItemReportByPartyReportData> {
  FutureOr<ItemReportByPartyReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<ItemReportByPartyReportData>,
              ItemReportByPartyReportData
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ItemReportByPartyReportData>,
                ItemReportByPartyReportData
              >,
              AsyncValue<ItemReportByPartyReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ItemWiseProfitLossReport)
final itemWiseProfitLossReportProvider = ItemWiseProfitLossReportProvider._();

final class ItemWiseProfitLossReportProvider
    extends
        $AsyncNotifierProvider<
          ItemWiseProfitLossReport,
          ItemWiseProfitLossReportData
        > {
  ItemWiseProfitLossReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemWiseProfitLossReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemWiseProfitLossReportHash();

  @$internal
  @override
  ItemWiseProfitLossReport create() => ItemWiseProfitLossReport();
}

String _$itemWiseProfitLossReportHash() =>
    r'a633b947acb080efb5034af07fd3e0016180f4c3';

abstract class _$ItemWiseProfitLossReport
    extends $AsyncNotifier<ItemWiseProfitLossReportData> {
  FutureOr<ItemWiseProfitLossReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<ItemWiseProfitLossReportData>,
              ItemWiseProfitLossReportData
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ItemWiseProfitLossReportData>,
                ItemWiseProfitLossReportData
              >,
              AsyncValue<ItemWiseProfitLossReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(StockDetailReport)
final stockDetailReportProvider = StockDetailReportProvider._();

final class StockDetailReportProvider
    extends $AsyncNotifierProvider<StockDetailReport, StockDetailReportData> {
  StockDetailReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stockDetailReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stockDetailReportHash();

  @$internal
  @override
  StockDetailReport create() => StockDetailReport();
}

String _$stockDetailReportHash() => r'0c178376730c6a43fbd94901eb2840c985dde7ee';

abstract class _$StockDetailReport
    extends $AsyncNotifier<StockDetailReportData> {
  FutureOr<StockDetailReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<StockDetailReportData>, StockDetailReportData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<StockDetailReportData>,
                StockDetailReportData
              >,
              AsyncValue<StockDetailReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ItemDetailReport)
final itemDetailReportProvider = ItemDetailReportProvider._();

final class ItemDetailReportProvider
    extends $AsyncNotifierProvider<ItemDetailReport, ItemDetailReportData?> {
  ItemDetailReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemDetailReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemDetailReportHash();

  @$internal
  @override
  ItemDetailReport create() => ItemDetailReport();
}

String _$itemDetailReportHash() => r'ae29a29993c559f97d21b346bd4595841bd85457';

abstract class _$ItemDetailReport
    extends $AsyncNotifier<ItemDetailReportData?> {
  FutureOr<ItemDetailReportData?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<ItemDetailReportData?>, ItemDetailReportData?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ItemDetailReportData?>,
                ItemDetailReportData?
              >,
              AsyncValue<ItemDetailReportData?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SalePurchaseByItemCategoryReport)
final salePurchaseByItemCategoryReportProvider =
    SalePurchaseByItemCategoryReportProvider._();

final class SalePurchaseByItemCategoryReportProvider
    extends
        $AsyncNotifierProvider<
          SalePurchaseByItemCategoryReport,
          CategoryAmountReportData
        > {
  SalePurchaseByItemCategoryReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'salePurchaseByItemCategoryReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$salePurchaseByItemCategoryReportHash();

  @$internal
  @override
  SalePurchaseByItemCategoryReport create() =>
      SalePurchaseByItemCategoryReport();
}

String _$salePurchaseByItemCategoryReportHash() =>
    r'16d35fcbcff2d5c318334cbc2c6344f15a81c56a';

abstract class _$SalePurchaseByItemCategoryReport
    extends $AsyncNotifier<CategoryAmountReportData> {
  FutureOr<CategoryAmountReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<CategoryAmountReportData>,
              CategoryAmountReportData
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<CategoryAmountReportData>,
                CategoryAmountReportData
              >,
              AsyncValue<CategoryAmountReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(StockSummaryByItemCategoryReport)
final stockSummaryByItemCategoryReportProvider =
    StockSummaryByItemCategoryReportProvider._();

final class StockSummaryByItemCategoryReportProvider
    extends
        $AsyncNotifierProvider<
          StockSummaryByItemCategoryReport,
          CategoryAmountReportData
        > {
  StockSummaryByItemCategoryReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stockSummaryByItemCategoryReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stockSummaryByItemCategoryReportHash();

  @$internal
  @override
  StockSummaryByItemCategoryReport create() =>
      StockSummaryByItemCategoryReport();
}

String _$stockSummaryByItemCategoryReportHash() =>
    r'3fc365e013a9801dc790cb6ff947d17c9f2ab861';

abstract class _$StockSummaryByItemCategoryReport
    extends $AsyncNotifier<CategoryAmountReportData> {
  FutureOr<CategoryAmountReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<CategoryAmountReportData>,
              CategoryAmountReportData
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<CategoryAmountReportData>,
                CategoryAmountReportData
              >,
              AsyncValue<CategoryAmountReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ItemCategoryWiseProfitLossReport)
final itemCategoryWiseProfitLossReportProvider =
    ItemCategoryWiseProfitLossReportProvider._();

final class ItemCategoryWiseProfitLossReportProvider
    extends
        $AsyncNotifierProvider<
          ItemCategoryWiseProfitLossReport,
          CategoryAmountReportData
        > {
  ItemCategoryWiseProfitLossReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemCategoryWiseProfitLossReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemCategoryWiseProfitLossReportHash();

  @$internal
  @override
  ItemCategoryWiseProfitLossReport create() =>
      ItemCategoryWiseProfitLossReport();
}

String _$itemCategoryWiseProfitLossReportHash() =>
    r'6046ea5b8971894284b778009555e272647b7f59';

abstract class _$ItemCategoryWiseProfitLossReport
    extends $AsyncNotifier<CategoryAmountReportData> {
  FutureOr<CategoryAmountReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<CategoryAmountReportData>,
              CategoryAmountReportData
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<CategoryAmountReportData>,
                CategoryAmountReportData
              >,
              AsyncValue<CategoryAmountReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ItemWiseDiscountReport)
final itemWiseDiscountReportProvider = ItemWiseDiscountReportProvider._();

final class ItemWiseDiscountReportProvider
    extends
        $AsyncNotifierProvider<
          ItemWiseDiscountReport,
          ItemWiseDiscountReportData
        > {
  ItemWiseDiscountReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemWiseDiscountReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemWiseDiscountReportHash();

  @$internal
  @override
  ItemWiseDiscountReport create() => ItemWiseDiscountReport();
}

String _$itemWiseDiscountReportHash() =>
    r'cb6b1e279af540cab4cd86aebeb5a832f5152419';

abstract class _$ItemWiseDiscountReport
    extends $AsyncNotifier<ItemWiseDiscountReportData> {
  FutureOr<ItemWiseDiscountReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<ItemWiseDiscountReportData>,
              ItemWiseDiscountReportData
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ItemWiseDiscountReportData>,
                ItemWiseDiscountReportData
              >,
              AsyncValue<ItemWiseDiscountReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ManufacturingReport)
final manufacturingReportProvider = ManufacturingReportProvider._();

final class ManufacturingReportProvider
    extends
        $AsyncNotifierProvider<ManufacturingReport, ManufacturingReportData> {
  ManufacturingReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'manufacturingReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$manufacturingReportHash();

  @$internal
  @override
  ManufacturingReport create() => ManufacturingReport();
}

String _$manufacturingReportHash() =>
    r'3f26e1235d212f806008b00b2422a385dee1b0f4';

abstract class _$ManufacturingReport
    extends $AsyncNotifier<ManufacturingReportData> {
  FutureOr<ManufacturingReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<ManufacturingReportData>,
              ManufacturingReportData
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ManufacturingReportData>,
                ManufacturingReportData
              >,
              AsyncValue<ManufacturingReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ConsumptionReport)
final consumptionReportProvider = ConsumptionReportProvider._();

final class ConsumptionReportProvider
    extends $AsyncNotifierProvider<ConsumptionReport, ConsumptionReportData> {
  ConsumptionReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'consumptionReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$consumptionReportHash();

  @$internal
  @override
  ConsumptionReport create() => ConsumptionReport();
}

String _$consumptionReportHash() => r'383ba69babf9b281a23728f0372df8179a984a56';

abstract class _$ConsumptionReport
    extends $AsyncNotifier<ConsumptionReportData> {
  FutureOr<ConsumptionReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<ConsumptionReportData>, ConsumptionReportData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ConsumptionReportData>,
                ConsumptionReportData
              >,
              AsyncValue<ConsumptionReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(StockTransferReport)
final stockTransferReportProvider = StockTransferReportProvider._();

final class StockTransferReportProvider
    extends
        $AsyncNotifierProvider<StockTransferReport, StockTransferReportData> {
  StockTransferReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stockTransferReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stockTransferReportHash();

  @$internal
  @override
  StockTransferReport create() => StockTransferReport();
}

String _$stockTransferReportHash() =>
    r'23b2c1a1818e5b6855d6bfa56f8660886a9204e9';

abstract class _$StockTransferReport
    extends $AsyncNotifier<StockTransferReportData> {
  FutureOr<StockTransferReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<StockTransferReportData>,
              StockTransferReportData
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<StockTransferReportData>,
                StockTransferReportData
              >,
              AsyncValue<StockTransferReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(BankStatementReport)
final bankStatementReportProvider = BankStatementReportProvider._();

final class BankStatementReportProvider
    extends
        $AsyncNotifierProvider<BankStatementReport, BankStatementReportData?> {
  BankStatementReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bankStatementReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bankStatementReportHash();

  @$internal
  @override
  BankStatementReport create() => BankStatementReport();
}

String _$bankStatementReportHash() =>
    r'6ec6ead3b311d98380c8a5a17d02bcc17859f07e';

abstract class _$BankStatementReport
    extends $AsyncNotifier<BankStatementReportData?> {
  FutureOr<BankStatementReportData?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<BankStatementReportData?>,
              BankStatementReportData?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<BankStatementReportData?>,
                BankStatementReportData?
              >,
              AsyncValue<BankStatementReportData?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(GstTaxReport)
final gstTaxReportProvider = GstTaxReportProvider._();

final class GstTaxReportProvider
    extends $AsyncNotifierProvider<GstTaxReport, GstTaxReportData> {
  GstTaxReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gstTaxReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gstTaxReportHash();

  @$internal
  @override
  GstTaxReport create() => GstTaxReport();
}

String _$gstTaxReportHash() => r'2fffe28bc3416def8c9b8eb93e70483755718ee9';

abstract class _$GstTaxReport extends $AsyncNotifier<GstTaxReportData> {
  FutureOr<GstTaxReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<GstTaxReportData>, GstTaxReportData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<GstTaxReportData>, GstTaxReportData>,
              AsyncValue<GstTaxReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(GstTaxRateReport)
final gstTaxRateReportProvider = GstTaxRateReportProvider._();

final class GstTaxRateReportProvider
    extends $AsyncNotifierProvider<GstTaxRateReport, GstTaxRateReportData> {
  GstTaxRateReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gstTaxRateReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gstTaxRateReportHash();

  @$internal
  @override
  GstTaxRateReport create() => GstTaxRateReport();
}

String _$gstTaxRateReportHash() => r'1f21cf747594ee5d68c7926ced14dcd2d11ab7b8';

abstract class _$GstTaxRateReport extends $AsyncNotifier<GstTaxRateReportData> {
  FutureOr<GstTaxRateReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<GstTaxRateReportData>, GstTaxRateReportData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<GstTaxRateReportData>,
                GstTaxRateReportData
              >,
              AsyncValue<GstTaxRateReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(Form27eqReport)
final form27eqReportProvider = Form27eqReportProvider._();

final class Form27eqReportProvider
    extends $AsyncNotifierProvider<Form27eqReport, TaxInvoiceReportData> {
  Form27eqReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'form27eqReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$form27eqReportHash();

  @$internal
  @override
  Form27eqReport create() => Form27eqReport();
}

String _$form27eqReportHash() => r'f16b033202f45509dc77ac6ea18e425e431e0996';

abstract class _$Form27eqReport extends $AsyncNotifier<TaxInvoiceReportData> {
  FutureOr<TaxInvoiceReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<TaxInvoiceReportData>, TaxInvoiceReportData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<TaxInvoiceReportData>,
                TaxInvoiceReportData
              >,
              AsyncValue<TaxInvoiceReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(TcsReceivableReport)
final tcsReceivableReportProvider = TcsReceivableReportProvider._();

final class TcsReceivableReportProvider
    extends $AsyncNotifierProvider<TcsReceivableReport, TaxInvoiceReportData> {
  TcsReceivableReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tcsReceivableReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tcsReceivableReportHash();

  @$internal
  @override
  TcsReceivableReport create() => TcsReceivableReport();
}

String _$tcsReceivableReportHash() =>
    r'4ccc00f3c4fc8515b4b552b6059d5cd1deb82ceb';

abstract class _$TcsReceivableReport
    extends $AsyncNotifier<TaxInvoiceReportData> {
  FutureOr<TaxInvoiceReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<TaxInvoiceReportData>, TaxInvoiceReportData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<TaxInvoiceReportData>,
                TaxInvoiceReportData
              >,
              AsyncValue<TaxInvoiceReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(TdsPayableReport)
final tdsPayableReportProvider = TdsPayableReportProvider._();

final class TdsPayableReportProvider
    extends $AsyncNotifierProvider<TdsPayableReport, TaxInvoiceReportData> {
  TdsPayableReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tdsPayableReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tdsPayableReportHash();

  @$internal
  @override
  TdsPayableReport create() => TdsPayableReport();
}

String _$tdsPayableReportHash() => r'c1fcd5d3e9e96b5c40c391c5a65f0e62025d20c7';

abstract class _$TdsPayableReport extends $AsyncNotifier<TaxInvoiceReportData> {
  FutureOr<TaxInvoiceReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<TaxInvoiceReportData>, TaxInvoiceReportData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<TaxInvoiceReportData>,
                TaxInvoiceReportData
              >,
              AsyncValue<TaxInvoiceReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(TdsReceivableReport)
final tdsReceivableReportProvider = TdsReceivableReportProvider._();

final class TdsReceivableReportProvider
    extends $AsyncNotifierProvider<TdsReceivableReport, TaxInvoiceReportData> {
  TdsReceivableReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tdsReceivableReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tdsReceivableReportHash();

  @$internal
  @override
  TdsReceivableReport create() => TdsReceivableReport();
}

String _$tdsReceivableReportHash() =>
    r'841b1b230eabbd71f257fa96bf43f90fa9390b7a';

abstract class _$TdsReceivableReport
    extends $AsyncNotifier<TaxInvoiceReportData> {
  FutureOr<TaxInvoiceReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<TaxInvoiceReportData>, TaxInvoiceReportData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<TaxInvoiceReportData>,
                TaxInvoiceReportData
              >,
              AsyncValue<TaxInvoiceReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ExpensesReport)
final expensesReportProvider = ExpensesReportProvider._();

final class ExpensesReportProvider
    extends $AsyncNotifierProvider<ExpensesReport, ExpensesReportData> {
  ExpensesReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expensesReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expensesReportHash();

  @$internal
  @override
  ExpensesReport create() => ExpensesReport();
}

String _$expensesReportHash() => r'fd3636ca1c1a554a26e8cabd0a9f457eb40dd659';

abstract class _$ExpensesReport extends $AsyncNotifier<ExpensesReportData> {
  FutureOr<ExpensesReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ExpensesReportData>, ExpensesReportData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ExpensesReportData>, ExpensesReportData>,
              AsyncValue<ExpensesReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ExpenseByCategoryReport)
final expenseByCategoryReportProvider = ExpenseByCategoryReportProvider._();

final class ExpenseByCategoryReportProvider
    extends
        $AsyncNotifierProvider<
          ExpenseByCategoryReport,
          ExpenseByCategoryReportData
        > {
  ExpenseByCategoryReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseByCategoryReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseByCategoryReportHash();

  @$internal
  @override
  ExpenseByCategoryReport create() => ExpenseByCategoryReport();
}

String _$expenseByCategoryReportHash() =>
    r'800d2f45bb5abe4fbc067874e858a6a3693f34b9';

abstract class _$ExpenseByCategoryReport
    extends $AsyncNotifier<ExpenseByCategoryReportData> {
  FutureOr<ExpenseByCategoryReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<ExpenseByCategoryReportData>,
              ExpenseByCategoryReportData
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ExpenseByCategoryReportData>,
                ExpenseByCategoryReportData
              >,
              AsyncValue<ExpenseByCategoryReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ExpenseByItemReport)
final expenseByItemReportProvider = ExpenseByItemReportProvider._();

final class ExpenseByItemReportProvider
    extends
        $AsyncNotifierProvider<ExpenseByItemReport, ExpenseByItemReportData> {
  ExpenseByItemReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseByItemReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseByItemReportHash();

  @$internal
  @override
  ExpenseByItemReport create() => ExpenseByItemReport();
}

String _$expenseByItemReportHash() =>
    r'558b821bfce40c269f8860962a675621f1541815';

abstract class _$ExpenseByItemReport
    extends $AsyncNotifier<ExpenseByItemReportData> {
  FutureOr<ExpenseByItemReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<ExpenseByItemReportData>,
              ExpenseByItemReportData
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ExpenseByItemReportData>,
                ExpenseByItemReportData
              >,
              AsyncValue<ExpenseByItemReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SalePurchaseOrdersReport)
final salePurchaseOrdersReportProvider = SalePurchaseOrdersReportProvider._();

final class SalePurchaseOrdersReportProvider
    extends
        $AsyncNotifierProvider<
          SalePurchaseOrdersReport,
          SalePurchaseOrdersReportData
        > {
  SalePurchaseOrdersReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'salePurchaseOrdersReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$salePurchaseOrdersReportHash();

  @$internal
  @override
  SalePurchaseOrdersReport create() => SalePurchaseOrdersReport();
}

String _$salePurchaseOrdersReportHash() =>
    r'99a7d1dece428b7108f316c00ba8a82d9d8ba4a7';

abstract class _$SalePurchaseOrdersReport
    extends $AsyncNotifier<SalePurchaseOrdersReportData> {
  FutureOr<SalePurchaseOrdersReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<SalePurchaseOrdersReportData>,
              SalePurchaseOrdersReportData
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<SalePurchaseOrdersReportData>,
                SalePurchaseOrdersReportData
              >,
              AsyncValue<SalePurchaseOrdersReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SalePurchaseOrderItemsReport)
final salePurchaseOrderItemsReportProvider =
    SalePurchaseOrderItemsReportProvider._();

final class SalePurchaseOrderItemsReportProvider
    extends
        $AsyncNotifierProvider<
          SalePurchaseOrderItemsReport,
          SalePurchaseOrderItemsReportData
        > {
  SalePurchaseOrderItemsReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'salePurchaseOrderItemsReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$salePurchaseOrderItemsReportHash();

  @$internal
  @override
  SalePurchaseOrderItemsReport create() => SalePurchaseOrderItemsReport();
}

String _$salePurchaseOrderItemsReportHash() =>
    r'b9bb8db88ba5ff7fafa3f232ebf67aabd6020cd6';

abstract class _$SalePurchaseOrderItemsReport
    extends $AsyncNotifier<SalePurchaseOrderItemsReportData> {
  FutureOr<SalePurchaseOrderItemsReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<SalePurchaseOrderItemsReportData>,
              SalePurchaseOrderItemsReportData
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<SalePurchaseOrderItemsReportData>,
                SalePurchaseOrderItemsReportData
              >,
              AsyncValue<SalePurchaseOrderItemsReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(OtherIncomeReport)
final otherIncomeReportProvider = OtherIncomeReportProvider._();

final class OtherIncomeReportProvider
    extends $AsyncNotifierProvider<OtherIncomeReport, OtherIncomeReportData> {
  OtherIncomeReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'otherIncomeReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$otherIncomeReportHash();

  @$internal
  @override
  OtherIncomeReport create() => OtherIncomeReport();
}

String _$otherIncomeReportHash() => r'8a8429264f32c25c2191feab3f3b72f908258ede';

abstract class _$OtherIncomeReport
    extends $AsyncNotifier<OtherIncomeReportData> {
  FutureOr<OtherIncomeReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<OtherIncomeReportData>, OtherIncomeReportData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<OtherIncomeReportData>,
                OtherIncomeReportData
              >,
              AsyncValue<OtherIncomeReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(OtherIncomeByCategoryReport)
final otherIncomeByCategoryReportProvider =
    OtherIncomeByCategoryReportProvider._();

final class OtherIncomeByCategoryReportProvider
    extends
        $AsyncNotifierProvider<
          OtherIncomeByCategoryReport,
          OtherIncomeByCategoryReportData
        > {
  OtherIncomeByCategoryReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'otherIncomeByCategoryReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$otherIncomeByCategoryReportHash();

  @$internal
  @override
  OtherIncomeByCategoryReport create() => OtherIncomeByCategoryReport();
}

String _$otherIncomeByCategoryReportHash() =>
    r'6a23b0e2092f8cc4b9b6a14fa34dc3181377356e';

abstract class _$OtherIncomeByCategoryReport
    extends $AsyncNotifier<OtherIncomeByCategoryReportData> {
  FutureOr<OtherIncomeByCategoryReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<OtherIncomeByCategoryReportData>,
              OtherIncomeByCategoryReportData
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<OtherIncomeByCategoryReportData>,
                OtherIncomeByCategoryReportData
              >,
              AsyncValue<OtherIncomeByCategoryReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(OtherIncomeByItemReport)
final otherIncomeByItemReportProvider = OtherIncomeByItemReportProvider._();

final class OtherIncomeByItemReportProvider
    extends
        $AsyncNotifierProvider<
          OtherIncomeByItemReport,
          OtherIncomeByItemReportData
        > {
  OtherIncomeByItemReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'otherIncomeByItemReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$otherIncomeByItemReportHash();

  @$internal
  @override
  OtherIncomeByItemReport create() => OtherIncomeByItemReport();
}

String _$otherIncomeByItemReportHash() =>
    r'973df11295346675b16a5e030a685ef42d01e200';

abstract class _$OtherIncomeByItemReport
    extends $AsyncNotifier<OtherIncomeByItemReportData> {
  FutureOr<OtherIncomeByItemReportData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<OtherIncomeByItemReportData>,
              OtherIncomeByItemReportData
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<OtherIncomeByItemReportData>,
                OtherIncomeByItemReportData
              >,
              AsyncValue<OtherIncomeByItemReportData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(LoanStatementReport)
final loanStatementReportProvider = LoanStatementReportProvider._();

final class LoanStatementReportProvider
    extends
        $AsyncNotifierProvider<LoanStatementReport, LoanStatementReportData?> {
  LoanStatementReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loanStatementReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loanStatementReportHash();

  @$internal
  @override
  LoanStatementReport create() => LoanStatementReport();
}

String _$loanStatementReportHash() =>
    r'b2af6d641d44e96f19c39efd6d43d4c0137e900d';

abstract class _$LoanStatementReport
    extends $AsyncNotifier<LoanStatementReportData?> {
  FutureOr<LoanStatementReportData?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<LoanStatementReportData?>,
              LoanStatementReportData?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<LoanStatementReportData?>,
                LoanStatementReportData?
              >,
              AsyncValue<LoanStatementReportData?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
