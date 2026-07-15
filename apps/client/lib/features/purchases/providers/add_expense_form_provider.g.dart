// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_expense_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddExpenseForm)
final addExpenseFormProvider = AddExpenseFormFamily._();

final class AddExpenseFormProvider
    extends $NotifierProvider<AddExpenseForm, AddExpenseFormState> {
  AddExpenseFormProvider._({
    required AddExpenseFormFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'addExpenseFormProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addExpenseFormHash();

  @override
  String toString() {
    return r'addExpenseFormProvider'
        ''
        '($argument)';
  }

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

  @override
  bool operator ==(Object other) {
    return other is AddExpenseFormProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addExpenseFormHash() => r'b0064f73efaede07187fbb896c9a25a978e94dad';

final class AddExpenseFormFamily extends $Family
    with
        $ClassFamilyOverride<
          AddExpenseForm,
          AddExpenseFormState,
          AddExpenseFormState,
          AddExpenseFormState,
          String?
        > {
  AddExpenseFormFamily._()
    : super(
        retry: null,
        name: r'addExpenseFormProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddExpenseFormProvider call({String? expenseId}) =>
      AddExpenseFormProvider._(argument: expenseId, from: this);

  @override
  String toString() => r'addExpenseFormProvider';
}

abstract class _$AddExpenseForm extends $Notifier<AddExpenseFormState> {
  late final _$args = ref.$arg as String?;
  String? get expenseId => _$args;

  AddExpenseFormState build({String? expenseId});
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
    return element.handleCreate(ref, () => build(expenseId: _$args));
  }
}

@ProviderFor(addExpenseGrandTotal)
final addExpenseGrandTotalProvider = AddExpenseGrandTotalFamily._();

final class AddExpenseGrandTotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  AddExpenseGrandTotalProvider._({
    required AddExpenseGrandTotalFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'addExpenseGrandTotalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addExpenseGrandTotalHash();

  @override
  String toString() {
    return r'addExpenseGrandTotalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    final argument = this.argument as String?;
    return addExpenseGrandTotal(ref, expenseId: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AddExpenseGrandTotalProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addExpenseGrandTotalHash() =>
    r'41f6f7e15226fde7f655e8c147aa717afb755a60';

final class AddExpenseGrandTotalFamily extends $Family
    with $FunctionalFamilyOverride<double, String?> {
  AddExpenseGrandTotalFamily._()
    : super(
        retry: null,
        name: r'addExpenseGrandTotalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddExpenseGrandTotalProvider call({String? expenseId}) =>
      AddExpenseGrandTotalProvider._(argument: expenseId, from: this);

  @override
  String toString() => r'addExpenseGrandTotalProvider';
}

@ProviderFor(addExpenseTotalTax)
final addExpenseTotalTaxProvider = AddExpenseTotalTaxFamily._();

final class AddExpenseTotalTaxProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  AddExpenseTotalTaxProvider._({
    required AddExpenseTotalTaxFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'addExpenseTotalTaxProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addExpenseTotalTaxHash();

  @override
  String toString() {
    return r'addExpenseTotalTaxProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    final argument = this.argument as String?;
    return addExpenseTotalTax(ref, expenseId: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AddExpenseTotalTaxProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addExpenseTotalTaxHash() =>
    r'496f7fa6855e7b1429f15682bdf9749c92bd788d';

final class AddExpenseTotalTaxFamily extends $Family
    with $FunctionalFamilyOverride<double, String?> {
  AddExpenseTotalTaxFamily._()
    : super(
        retry: null,
        name: r'addExpenseTotalTaxProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddExpenseTotalTaxProvider call({String? expenseId}) =>
      AddExpenseTotalTaxProvider._(argument: expenseId, from: this);

  @override
  String toString() => r'addExpenseTotalTaxProvider';
}

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
    r'b59541e113a213537f8c232edc5fc526a94b2a80';
