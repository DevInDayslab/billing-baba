// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_fa_tabs_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SaleFaTabs)
final saleFaTabsProvider = SaleFaTabsFamily._();

final class SaleFaTabsProvider
    extends $NotifierProvider<SaleFaTabs, SaleFaTabsState> {
  SaleFaTabsProvider._({
    required SaleFaTabsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'saleFaTabsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$saleFaTabsHash();

  @override
  String toString() {
    return r'saleFaTabsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SaleFaTabs create() => SaleFaTabs();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaleFaTabsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaleFaTabsState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SaleFaTabsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$saleFaTabsHash() => r'a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0';

final class SaleFaTabsFamily extends $Family
    with
        $ClassFamilyOverride<
          SaleFaTabs,
          SaleFaTabsState,
          SaleFaTabsState,
          SaleFaTabsState,
          String?
        > {
  SaleFaTabsFamily._()
    : super(
        retry: null,
        name: r'saleFaTabsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SaleFaTabsProvider call({String? initialBatchId}) =>
      SaleFaTabsProvider._(argument: initialBatchId, from: this);

  @override
  String toString() => r'saleFaTabsProvider';
}

abstract class _$SaleFaTabs extends $Notifier<SaleFaTabsState> {
  late final _$args = ref.$arg as String?;
  String? get initialBatchId => _$args;

  SaleFaTabsState build({String? initialBatchId});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SaleFaTabsState, SaleFaTabsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SaleFaTabsState, SaleFaTabsState>,
              SaleFaTabsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(initialBatchId: _$args));
  }
}
