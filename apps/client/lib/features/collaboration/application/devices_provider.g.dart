// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'devices_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Devices)
final devicesProvider = DevicesProvider._();

final class DevicesProvider
    extends $AsyncNotifierProvider<Devices, List<ConnectedDevice>> {
  DevicesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'devicesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$devicesHash();

  @$internal
  @override
  Devices create() => Devices();
}

String _$devicesHash() => r'8f8d6d010696dfc1aea457227412a051651954c3';

abstract class _$Devices extends $AsyncNotifier<List<ConnectedDevice>> {
  FutureOr<List<ConnectedDevice>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<ConnectedDevice>>, List<ConnectedDevice>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ConnectedDevice>>,
                List<ConnectedDevice>
              >,
              AsyncValue<List<ConnectedDevice>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
