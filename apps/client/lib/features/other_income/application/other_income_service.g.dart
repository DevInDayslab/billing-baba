// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'other_income_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(otherIncomeService)
final otherIncomeServiceProvider = OtherIncomeServiceProvider._();

final class OtherIncomeServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<OtherIncomeService>,
          OtherIncomeService,
          FutureOr<OtherIncomeService>
        >
    with
        $FutureModifier<OtherIncomeService>,
        $FutureProvider<OtherIncomeService> {
  OtherIncomeServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'otherIncomeServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$otherIncomeServiceHash();

  @$internal
  @override
  $FutureProviderElement<OtherIncomeService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<OtherIncomeService> create(Ref ref) {
    return otherIncomeService(ref);
  }
}

String _$otherIncomeServiceHash() =>
    r'79358dae273a55d741b531983566e8bcc37782d4';
