// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_expense_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddExpenseForm)
final addExpenseFormProvider = AddExpenseFormProvider._();

final class AddExpenseFormProvider
    extends $NotifierProvider<AddExpenseForm, AddExpenseFormState> {
  AddExpenseFormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addExpenseFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addExpenseFormHash();

  @$internal
  @override
  AddExpenseForm create() => AddExpenseForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddExpenseFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddExpenseFormState>(value),
    );
  }
}

String _$addExpenseFormHash() => r'61542261e42986fc32ca5cc1e4abe9b1b4f5d546';

abstract class _$AddExpenseForm extends $Notifier<AddExpenseFormState> {
  AddExpenseFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AddExpenseFormState, AddExpenseFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AddExpenseFormState, AddExpenseFormState>,
              AddExpenseFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(addExpenseGrandTotal)
final addExpenseGrandTotalProvider = AddExpenseGrandTotalProvider._();

final class AddExpenseGrandTotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  AddExpenseGrandTotalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addExpenseGrandTotalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addExpenseGrandTotalHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return addExpenseGrandTotal(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$addExpenseGrandTotalHash() =>
    r'91d9200201f1a0501acb69cf8972c5eb120cf1bc';

@ProviderFor(addExpenseTotalTax)
final addExpenseTotalTaxProvider = AddExpenseTotalTaxProvider._();

final class AddExpenseTotalTaxProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  AddExpenseTotalTaxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addExpenseTotalTaxProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addExpenseTotalTaxHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return addExpenseTotalTax(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$addExpenseTotalTaxHash() =>
    r'f5e76cb3d9d6565bce0bbdc517dc7a366f76fd5f';

@ProviderFor(expenseCategoryOptions)
final expenseCategoryOptionsProvider = ExpenseCategoryOptionsProvider._();

final class ExpenseCategoryOptionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  ExpenseCategoryOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseCategoryOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseCategoryOptionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return expenseCategoryOptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$expenseCategoryOptionsHash() =>
    r'41fc999a71174cbd6cb4fe98aaeb997c7439abda';
