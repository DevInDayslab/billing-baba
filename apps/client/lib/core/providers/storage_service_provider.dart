import 'package:billing_baba/core/services/storage_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'storage_service_provider.g.dart';

@Riverpod(keepAlive: true)
Future<StorageService> storageService(Ref ref) async {
  final service = StorageService();
  await service.init();
  return service;
}
