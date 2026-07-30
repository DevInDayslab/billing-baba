// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_preset_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(permissionPreset)
final permissionPresetProvider = PermissionPresetFamily._();

final class PermissionPresetProvider
    extends
        $FunctionalProvider<
          PermissionPreset,
          PermissionPreset,
          PermissionPreset
        >
    with $Provider<PermissionPreset> {
  PermissionPresetProvider._({
    required PermissionPresetFamily super.from,
    required Role super.argument,
  }) : super(
         retry: null,
         name: r'permissionPresetProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$permissionPresetHash();

  @override
  String toString() {
    return r'permissionPresetProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<PermissionPreset> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PermissionPreset create(Ref ref) {
    final argument = this.argument as Role;
    return permissionPreset(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PermissionPreset value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PermissionPreset>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PermissionPresetProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$permissionPresetHash() => r'6865bd8e8103f246f0b471d9c63aef3b4483186d';

final class PermissionPresetFamily extends $Family
    with $FunctionalFamilyOverride<PermissionPreset, Role> {
  PermissionPresetFamily._()
    : super(
        retry: null,
        name: r'permissionPresetProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PermissionPresetProvider call(Role role) =>
      PermissionPresetProvider._(argument: role, from: this);

  @override
  String toString() => r'permissionPresetProvider';
}
