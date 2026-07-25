import 'package:billing_baba/features/collaboration/application/collaboration_repository_provider.dart';
import 'package:billing_baba/features/collaboration/domain/models/connected_device.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_init_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'devices_provider.g.dart';

@Riverpod(keepAlive: true)
class Devices extends _$Devices {
  @override
  Future<List<ConnectedDevice>> build() async {
    ref.watch(collaborationInitProvider);
    final service = ref.watch(collaborationServiceProvider);
    return service.fetchDevices();
  }

  Future<void> reload({bool showLoading = true}) async {
    if (showLoading) {
      state = const AsyncLoading();
    }
    state = await AsyncValue.guard(() async {
      final service = ref.read(collaborationServiceProvider);
      return service.fetchDevices();
    });
  }
}
