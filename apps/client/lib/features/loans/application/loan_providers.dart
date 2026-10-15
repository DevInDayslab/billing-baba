import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/core/sync/providers/sync_providers.dart';
import 'package:billing_baba/features/loans/data/loan_account_local_source.dart';
import 'package:billing_baba/features/loans/data/loan_command_repository.dart';
import 'package:billing_baba/features/loans/data/loan_remote_data_source.dart';
import 'package:billing_baba/features/loans/data/loan_sync.dart';
import 'package:billing_baba/features/loans/data/loan_transaction_local_source.dart';
import 'package:billing_baba/features/loans/models/loan_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loanAccountLocalSourceProvider = Provider<LoanAccountLocalSource>((ref) {
  return LoanAccountLocalSource(ref.watch(appDatabaseProvider));
});

final loanTransactionLocalSourceProvider =
    Provider<LoanTransactionLocalSource>((ref) {
  return LoanTransactionLocalSource(ref.watch(appDatabaseProvider));
});

final loanRemoteProvider = FutureProvider<LoanRemoteDataSource>((ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return LoanRemoteDataSource(api.dio);
});

final loanCommandRepositoryProvider =
    FutureProvider<LoanCommandRepository>((ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  String? deviceId;
  try {
    final identity = await ref.watch(syncDeviceIdentityProvider.future);
    deviceId = await identity.deviceId();
  } on Object {
    deviceId = null;
  }
  return LoanCommandRepository(
    db: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueProvider),
    businessIdReader: () =>
        storage.read(StorageKeys.lastOpenedBusinessId) ?? '',
    deviceIdReader: () => deviceId,
  );
});

final loanAccountsHydrationProvider = FutureProvider<void>((ref) async {
  final businessId = ref.watch(currentBusinessProvider)?.id ?? '';
  if (businessId.isEmpty) return;

  final local = ref.read(loanAccountLocalSourceProvider);
  if ((await local.listActive(businessId)).isNotEmpty) return;

  try {
    final remote = await ref.read(loanRemoteProvider.future);
    final accounts = await remote.listAccounts();
    if (accounts.isEmpty) return;

    final sync = LoanAccountSync(ref.read(appDatabaseProvider));
    final now = DateTime.now().toUtc();
    for (final account in accounts) {
      await sync.applyChange(
        businessId: businessId,
        entityId: account.id,
        syncVersion: 1,
        updatedAt: now,
        isDeleted: false,
        payload: account.toSyncPayload(),
      );
    }
  } catch (_) {
    // Offline — local picker stays empty until sync pull.
  }
});

final loanAccountsStreamProvider = StreamProvider<List<LoanAccountDto>>((ref) {
  final businessId = ref.watch(currentBusinessProvider)?.id ?? '';
  if (businessId.isEmpty) {
    return Stream.value(const []);
  }
  ref.watch(loanAccountsHydrationProvider);
  return ref.watch(loanAccountLocalSourceProvider).watchActive(businessId);
});

final loanAccountByIdProvider =
    FutureProvider.family<LoanAccountDto?, String>((ref, id) async {
  if (id.isEmpty) return null;
  final local = ref.read(loanAccountLocalSourceProvider);
  final cached = await local.getById(id);
  if (cached != null) return cached;
  try {
    final remote = await ref.read(loanRemoteProvider.future);
    return remote.getAccount(id);
  } catch (_) {
    return null;
  }
});

final loanTransactionsForAccountProvider = StreamProvider.family<
    List<LoanTransactionDto>,
    String>((ref, loanAccountId) {
  final businessId = ref.watch(currentBusinessProvider)?.id ?? '';
  if (businessId.isEmpty || loanAccountId.isEmpty) {
    return Stream.value(const []);
  }
  return ref
      .watch(loanTransactionLocalSourceProvider)
      .watchForAccount(businessId: businessId, loanAccountId: loanAccountId);
});
