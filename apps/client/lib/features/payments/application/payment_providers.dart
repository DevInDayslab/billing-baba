import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/payments/data/payment_api.dart';
import 'package:billing_baba/features/payments/data/payment_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentApiProvider = FutureProvider<PaymentApi>((ref) async {
  final client = await ref.watch(apiClientProvider.future);
  return PaymentApi(client.dio);
});

final paymentRepositoryProvider = FutureProvider<PaymentRepository>((ref) async {
  final api = await ref.watch(paymentApiProvider.future);
  final db = ref.watch(appDatabaseProvider);
  return PaymentRepository(api: api, database: db);
});
