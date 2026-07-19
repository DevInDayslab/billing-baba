// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_message_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(transactionMessageSettingsRepository)
final transactionMessageSettingsRepositoryProvider =
    TransactionMessageSettingsRepositoryProvider._();

final class TransactionMessageSettingsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<TransactionMessageSettingsRepository>,
          TransactionMessageSettingsRepository,
          FutureOr<TransactionMessageSettingsRepository>
        >
    with
        $FutureModifier<TransactionMessageSettingsRepository>,
        $FutureProvider<TransactionMessageSettingsRepository> {
  TransactionMessageSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionMessageSettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$transactionMessageSettingsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<TransactionMessageSettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TransactionMessageSettingsRepository> create(Ref ref) {
    return transactionMessageSettingsRepository(ref);
  }
}

String _$transactionMessageSettingsRepositoryHash() =>
    r'5db1f7de71026ed2e4fc4de54997df08bfe161a0';

@ProviderFor(TransactionMessageSettingsNotifier)
final transactionMessageSettingsProvider =
    TransactionMessageSettingsNotifierProvider._();

final class TransactionMessageSettingsNotifierProvider
    extends
        $AsyncNotifierProvider<
          TransactionMessageSettingsNotifier,
          TransactionMessageSettings
        > {
  TransactionMessageSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionMessageSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$transactionMessageSettingsNotifierHash();

  @$internal
  @override
  TransactionMessageSettingsNotifier create() =>
      TransactionMessageSettingsNotifier();
}

String _$transactionMessageSettingsNotifierHash() =>
    r'ced8ad24abc9ce840b79068ef07b64207aff0fcb';

abstract class _$TransactionMessageSettingsNotifier
    extends $AsyncNotifier<TransactionMessageSettings> {
  FutureOr<TransactionMessageSettings> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<TransactionMessageSettings>,
              TransactionMessageSettings
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<TransactionMessageSettings>,
                TransactionMessageSettings
              >,
              AsyncValue<TransactionMessageSettings>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
