// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_other_income_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddOtherIncomeForm)
final addOtherIncomeFormProvider = AddOtherIncomeFormFamily._();

final class AddOtherIncomeFormProvider
    extends $NotifierProvider<AddOtherIncomeForm, AddOtherIncomeFormState> {
  AddOtherIncomeFormProvider._({
    required AddOtherIncomeFormFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'addOtherIncomeFormProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addOtherIncomeFormHash();

  @override
  String toString() {
    return r'addOtherIncomeFormProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AddOtherIncomeForm create() => AddOtherIncomeForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddOtherIncomeFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddOtherIncomeFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AddOtherIncomeFormProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addOtherIncomeFormHash() =>
    r'a74e8b37621f63f199d86288f602d5e7e1622240';

final class AddOtherIncomeFormFamily extends $Family
    with
        $ClassFamilyOverride<
          AddOtherIncomeForm,
          AddOtherIncomeFormState,
          AddOtherIncomeFormState,
          AddOtherIncomeFormState,
          String?
        > {
  AddOtherIncomeFormFamily._()
    : super(
        retry: null,
        name: r'addOtherIncomeFormProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddOtherIncomeFormProvider call({String? incomeId}) =>
      AddOtherIncomeFormProvider._(argument: incomeId, from: this);

  @override
  String toString() => r'addOtherIncomeFormProvider';
}

abstract class _$AddOtherIncomeForm extends $Notifier<AddOtherIncomeFormState> {
  late final _$args = ref.$arg as String?;
  String? get incomeId => _$args;

  AddOtherIncomeFormState build({String? incomeId});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AddOtherIncomeFormState, AddOtherIncomeFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AddOtherIncomeFormState, AddOtherIncomeFormState>,
              AddOtherIncomeFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(incomeId: _$args));
  }
}

@ProviderFor(addOtherIncomeGrandTotal)
final addOtherIncomeGrandTotalProvider = AddOtherIncomeGrandTotalFamily._();

final class AddOtherIncomeGrandTotalProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  AddOtherIncomeGrandTotalProvider._({
    required AddOtherIncomeGrandTotalFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'addOtherIncomeGrandTotalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addOtherIncomeGrandTotalHash();

  @override
  String toString() {
    return r'addOtherIncomeGrandTotalProvider'
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
    return addOtherIncomeGrandTotal(ref, incomeId: argument);
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
    return other is AddOtherIncomeGrandTotalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addOtherIncomeGrandTotalHash() =>
    r'5525512c482e8299b55894ab875db5ef3f09fb04';

final class AddOtherIncomeGrandTotalFamily extends $Family
    with $FunctionalFamilyOverride<double, String?> {
  AddOtherIncomeGrandTotalFamily._()
    : super(
        retry: null,
        name: r'addOtherIncomeGrandTotalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddOtherIncomeGrandTotalProvider call({String? incomeId}) =>
      AddOtherIncomeGrandTotalProvider._(argument: incomeId, from: this);

  @override
  String toString() => r'addOtherIncomeGrandTotalProvider';
}

@ProviderFor(addOtherIncomeTotalTax)
final addOtherIncomeTotalTaxProvider = AddOtherIncomeTotalTaxFamily._();

final class AddOtherIncomeTotalTaxProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  AddOtherIncomeTotalTaxProvider._({
    required AddOtherIncomeTotalTaxFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'addOtherIncomeTotalTaxProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addOtherIncomeTotalTaxHash();

  @override
  String toString() {
    return r'addOtherIncomeTotalTaxProvider'
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
    return addOtherIncomeTotalTax(ref, incomeId: argument);
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
    return other is AddOtherIncomeTotalTaxProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addOtherIncomeTotalTaxHash() =>
    r'754b0dc60c3bbd9f4eb0b3ae5ae238b968959bf2';

final class AddOtherIncomeTotalTaxFamily extends $Family
    with $FunctionalFamilyOverride<double, String?> {
  AddOtherIncomeTotalTaxFamily._()
    : super(
        retry: null,
        name: r'addOtherIncomeTotalTaxProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddOtherIncomeTotalTaxProvider call({String? incomeId}) =>
      AddOtherIncomeTotalTaxProvider._(argument: incomeId, from: this);

  @override
  String toString() => r'addOtherIncomeTotalTaxProvider';
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
    r'916c1ad4296afc5afe268b436ec21948364aa307';
