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
    r'c00b8234bc3de4423ba17558e854cf166114cc72';

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

@ProviderFor(loggedInPhone)
final loggedInPhoneProvider = LoggedInPhoneProvider._();

final class LoggedInPhoneProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  LoggedInPhoneProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loggedInPhoneProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loggedInPhoneHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return loggedInPhone(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$loggedInPhoneHash() => r'077cc4c7b9570458e2c25dbb23e64d38417da122';
