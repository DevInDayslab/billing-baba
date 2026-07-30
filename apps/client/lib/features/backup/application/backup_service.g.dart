// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(backupService)
final backupServiceProvider = BackupServiceProvider._();

final class BackupServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<BackupService>,
          BackupService,
          FutureOr<BackupService>
        >
    with $FutureModifier<BackupService>, $FutureProvider<BackupService> {
  BackupServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupServiceHash();

  @$internal
  @override
  $FutureProviderElement<BackupService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BackupService> create(Ref ref) {
    return backupService(ref);
  }
}

String _$backupServiceHash() => r'13df1687ac78f8e89698cde6ed05cd58ce40b367';
