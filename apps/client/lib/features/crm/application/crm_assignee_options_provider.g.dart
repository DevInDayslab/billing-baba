// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crm_assignee_options_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(crmAssigneeNames)
final crmAssigneeNamesProvider = CrmAssigneeNamesProvider._();

final class CrmAssigneeNamesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  CrmAssigneeNamesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crmAssigneeNamesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crmAssigneeNamesHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return crmAssigneeNames(ref);
  }
}

String _$crmAssigneeNamesHash() => r'0568ce6db86c9bad704ff7e994982afd9c364597';

@ProviderFor(crmAssigneeFormOptions)
final crmAssigneeFormOptionsProvider = CrmAssigneeFormOptionsProvider._();

final class CrmAssigneeFormOptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  CrmAssigneeFormOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crmAssigneeFormOptionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crmAssigneeFormOptionsHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return crmAssigneeFormOptions(ref);
  }
}

String _$crmAssigneeFormOptionsHash() =>
    r'e3b435215b3a553b8f49a8e486c14e3455d4ad3b';

@ProviderFor(crmAssigneeFilterOptions)
final crmAssigneeFilterOptionsProvider = CrmAssigneeFilterOptionsProvider._();

final class CrmAssigneeFilterOptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  CrmAssigneeFilterOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crmAssigneeFilterOptionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crmAssigneeFilterOptionsHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return crmAssigneeFilterOptions(ref);
  }
}

String _$crmAssigneeFilterOptionsHash() =>
    r'41c13d552bc06db26eacf5f162ce3a4d25fa9192';

@ProviderFor(crmDefaultOwnerName)
final crmDefaultOwnerNameProvider = CrmDefaultOwnerNameProvider._();

final class CrmDefaultOwnerNameProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  CrmDefaultOwnerNameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crmDefaultOwnerNameProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crmDefaultOwnerNameHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return crmDefaultOwnerName(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$crmDefaultOwnerNameHash() =>
    r'3eb133615eab01637f018a177591ef3622c47501';
