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

String _$businessListHash() => r'933e168b6891dd6d939571815cef597010befe19';

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

@ProviderFor(BusinessProfile)
final businessProfileProvider = BusinessProfileProvider._();

final class BusinessProfileProvider
    extends $AsyncNotifierProvider<BusinessProfile, BusinessProfileModel> {
  BusinessProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'businessProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$businessProfileHash();

  @$internal
  @override
  BusinessProfile create() => BusinessProfile();
}

String _$businessProfileHash() => r'e2845c49a2df0657e8c8dccac1e4c0b1cd57b1a3';

abstract class _$BusinessProfile extends $AsyncNotifier<BusinessProfileModel> {
  FutureOr<BusinessProfileModel> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<BusinessProfileModel>, BusinessProfileModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<BusinessProfileModel>,
                BusinessProfileModel
              >,
              AsyncValue<BusinessProfileModel>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(currentBusiness)
final currentBusinessProvider = CurrentBusinessProvider._();

final class CurrentBusinessProvider
    extends
        $FunctionalProvider<
          BusinessProfileModel?,
          BusinessProfileModel?,
          BusinessProfileModel?
        >
    with $Provider<BusinessProfileModel?> {
  CurrentBusinessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentBusinessProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentBusinessHash();

  @$internal
  @override
  $ProviderElement<BusinessProfileModel?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BusinessProfileModel? create(Ref ref) {
    return currentBusiness(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BusinessProfileModel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BusinessProfileModel?>(value),
    );
  }
}

String _$currentBusinessHash() => r'94dfd8ed353d0789b350de47bf74ada3441d6835';

@ProviderFor(sidebarBusiness)
final sidebarBusinessProvider = SidebarBusinessProvider._();

final class SidebarBusinessProvider
    extends
        $FunctionalProvider<SidebarBusiness, SidebarBusiness, SidebarBusiness>
    with $Provider<SidebarBusiness> {
  SidebarBusinessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sidebarBusinessProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sidebarBusinessHash();

  @$internal
  @override
  $ProviderElement<SidebarBusiness> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SidebarBusiness create(Ref ref) {
    return sidebarBusiness(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SidebarBusiness value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SidebarBusiness>(value),
    );
  }
}

String _$sidebarBusinessHash() => r'592c70e79876d865db90fc7d62fcc22c8332bb0e';
