// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_access_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(companyAccess)
final companyAccessProvider = CompanyAccessProvider._();

final class CompanyAccessProvider
    extends
        $FunctionalProvider<
          AsyncValue<CompanyAccess>,
          CompanyAccess,
          FutureOr<CompanyAccess>
        >
    with $FutureModifier<CompanyAccess>, $FutureProvider<CompanyAccess> {
  CompanyAccessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'companyAccessProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$companyAccessHash();

  @$internal
  @override
  $FutureProviderElement<CompanyAccess> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CompanyAccess> create(Ref ref) {
    return companyAccess(ref);
  }
}

String _$companyAccessHash() => r'8fc4d6baeef6d389b7cda97db4f4fd672fe9af8e';
