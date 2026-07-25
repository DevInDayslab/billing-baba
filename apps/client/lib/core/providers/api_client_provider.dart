import 'package:billing_baba/core/network/api_client.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client_provider.g.dart';

@Riverpod(keepAlive: true)
Future<ApiClient> apiClient(Ref ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  return ApiClient(
    storage: storage,
    onRefreshToken: () async {
      final session = await ref
          .read(authProvider.notifier)
          .refreshAccessToken();
      return session?.accessToken;
    },
  );
}
