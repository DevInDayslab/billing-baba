// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_business_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreateBusinessForm)
final createBusinessFormProvider = CreateBusinessFormProvider._();

final class CreateBusinessFormProvider
    extends $NotifierProvider<CreateBusinessForm, CreateBusinessFormState> {
  CreateBusinessFormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createBusinessFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createBusinessFormHash();

  @$internal
  @override
  CreateBusinessForm create() => CreateBusinessForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateBusinessFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateBusinessFormState>(value),
    );
  }
}

String _$createBusinessFormHash() =>
    r'ef2286bf3be6a7275e49eef9d5796d1eb8569cb0';

abstract class _$CreateBusinessForm extends $Notifier<CreateBusinessFormState> {
  CreateBusinessFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<CreateBusinessFormState, CreateBusinessFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CreateBusinessFormState, CreateBusinessFormState>,
              CreateBusinessFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
