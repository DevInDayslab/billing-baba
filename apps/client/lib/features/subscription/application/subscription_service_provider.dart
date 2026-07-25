import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/subscription/application/subscription_service.dart';
import 'package:billing_baba/features/subscription/data/subscription_api.dart';
import 'package:billing_baba/features/subscription/data/subscription_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_service_provider.g.dart';

@Riverpod(keepAlive: true)
Future<SubscriptionService> subscriptionService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  final repository = SubscriptionRepository(api: SubscriptionApi(api.dio));
  return SubscriptionService(repository);
}
