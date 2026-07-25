import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/settings/data/notifications_remote_data_source.dart';
import 'package:billing_baba/features/settings/repositories/notifications_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notifications_remote_provider.g.dart';

@Riverpod(keepAlive: true)
Future<NotificationsRemoteDataSource> notificationsRemote(Ref ref) async {
  final client = await ref.watch(apiClientProvider.future);
  return NotificationsRemoteDataSource(client.dio);
}

@Riverpod(keepAlive: true)
Future<NotificationsRepository> notificationsRepository(Ref ref) async {
  final remote = await ref.watch(notificationsRemoteProvider.future);
  return NotificationsRepository(remote);
}
