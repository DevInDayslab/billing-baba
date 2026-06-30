// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BusinessListNotifier)
final businessListProvider = BusinessListNotifierProvider._();

final class BusinessListNotifierProvider
    extends $NotifierProvider<BusinessListNotifier, List<BusinessModel>> {
  BusinessListNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'businessListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$businessListNotifierHash();

  @$internal
  @override
  BusinessListNotifier create() => BusinessListNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<BusinessModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<BusinessModel>>(value),
    );
  }
}

String _$businessListNotifierHash() =>
    r'457e29b3c2074cd36d0dbe64522ad177a2f75ebd';

abstract class _$BusinessListNotifier extends $Notifier<List<BusinessModel>> {
  List<BusinessModel> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<BusinessModel>, List<BusinessModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<BusinessModel>, List<BusinessModel>>,
              List<BusinessModel>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
