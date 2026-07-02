// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EditBusinessProfileForm)
final editBusinessProfileFormProvider = EditBusinessProfileFormProvider._();

final class EditBusinessProfileFormProvider
    extends
        $NotifierProvider<
          EditBusinessProfileForm,
          EditBusinessProfileFormState
        > {
  EditBusinessProfileFormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'editBusinessProfileFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$editBusinessProfileFormHash();

  @$internal
  @override
  EditBusinessProfileForm create() => EditBusinessProfileForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EditBusinessProfileFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EditBusinessProfileFormState>(value),
    );
  }
}

String _$editBusinessProfileFormHash() =>
    r'1f417a6b209a231bfb1b17b31d04737aadc563c7';

abstract class _$EditBusinessProfileForm
    extends $Notifier<EditBusinessProfileFormState> {
  EditBusinessProfileFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<EditBusinessProfileFormState, EditBusinessProfileFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                EditBusinessProfileFormState,
                EditBusinessProfileFormState
              >,
              EditBusinessProfileFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
