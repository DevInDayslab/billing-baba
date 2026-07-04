// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(expenseService)
final expenseServiceProvider = ExpenseServiceProvider._();

final class ExpenseServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<ExpenseService>,
          ExpenseService,
          FutureOr<ExpenseService>
        >
    with $FutureModifier<ExpenseService>, $FutureProvider<ExpenseService> {
  ExpenseServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseServiceHash();

  @$internal
  @override
  $FutureProviderElement<ExpenseService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ExpenseService> create(Ref ref) {
    return expenseService(ref);
  }
}

String _$expenseServiceHash() => r'5302d22693e1208f261690d2d3df2a6e8f1a6fce';
