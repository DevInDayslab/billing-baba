import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/bank_accounts/data/bank_account_local_source.dart';
import 'package:billing_baba/features/bank_accounts/data/bank_account_remote_data_source.dart';
import 'package:billing_baba/features/bank_accounts/data/bank_account_sync.dart';
import 'package:billing_baba/features/bank_accounts/models/bank_account_models.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bankAccountLocalSourceProvider = Provider<BankAccountLocalSource>((ref) {
  return BankAccountLocalSource(ref.watch(appDatabaseProvider));
});

final bankAccountRemoteProvider = FutureProvider<BankAccountRemoteDataSource>((
  ref,
) async {
  final api = await ref.watch(apiClientProvider.future);
  return BankAccountRemoteDataSource(api.dio);
});

/// Loads bank accounts from API into Drift when local cache is empty (e.g. before sync pull).
final bankAccountsHydrationProvider = FutureProvider<void>((ref) async {
  final businessId = ref.watch(currentBusinessProvider)?.id ?? '';
  if (businessId.isEmpty) return;

  final local = ref.read(bankAccountLocalSourceProvider);
  if ((await local.listActive(businessId)).isNotEmpty) return;

  try {
    final remote = await ref.read(bankAccountRemoteProvider.future);
    final accounts = await remote.listAccounts();
    if (accounts.isEmpty) return;

    final sync = BankAccountSync(ref.read(appDatabaseProvider));
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
    // Offline or unauthorized — picker shows empty state.
  }
});

final bankAccountsStreamProvider = StreamProvider<List<BankAccountDto>>((ref) {
  final businessId = ref.watch(currentBusinessProvider)?.id ?? '';
  if (businessId.isEmpty) {
    return Stream.value(const []);
  }
  ref.watch(bankAccountsHydrationProvider);
  return ref.watch(bankAccountLocalSourceProvider).watchActive(businessId);
});

final bankAccountBalancesProvider =
    FutureProvider<List<BankAccountBalanceDto>>((ref) async {
  final remote = await ref.watch(bankAccountRemoteProvider.future);
  return remote.listBalances();
});

final defaultBankAccountProvider = Provider<BankAccountDto?>((ref) {
  final accounts =
      ref.watch(bankAccountsStreamProvider).asData?.value ?? <BankAccountDto>[];
  final banks = accounts.where((a) => a.type == 'bank').toList();
  if (banks.isEmpty) return null;
  return banks.firstWhere((a) => a.isDefault, orElse: () => banks.first);
});
