// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(businessService)
final businessServiceProvider = BusinessServiceProvider._();

final class BusinessServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<BusinessService>,
          BusinessService,
          FutureOr<BusinessService>
        >
    with $FutureModifier<BusinessService>, $FutureProvider<BusinessService> {
  BusinessServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'businessServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$businessServiceHash();

  @$internal
  @override
  $FutureProviderElement<BusinessService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BusinessService> create(Ref ref) {
    return businessService(ref);
  }
}

String _$businessServiceHash() => r'7709cdf569c2fbe2557b58c0ceae18c3a6d065ec';

@ProviderFor(BusinessList)
final businessListProvider = BusinessListProvider._();

final class BusinessListProvider
    extends $AsyncNotifierProvider<BusinessList, List<BusinessModel>> {
  BusinessListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'businessListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$businessListHash();

  @$internal
  @override
  BusinessList create() => BusinessList();
}

String _$businessListHash() => r'30b59b50a2fa513ae7c43ec911900e3aa6eb3ed3';

abstract class _$BusinessList extends $AsyncNotifier<List<BusinessModel>> {
  FutureOr<List<BusinessModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<BusinessModel>>, List<BusinessModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<BusinessModel>>, List<BusinessModel>>,
              AsyncValue<List<BusinessModel>>,
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
