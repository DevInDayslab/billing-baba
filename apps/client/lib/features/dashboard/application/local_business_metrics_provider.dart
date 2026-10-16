import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/providers/async_provider_guard.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/dashboard/application/local_business_metrics_service.dart';
import 'package:billing_baba/features/parties/application/party_ledger_service.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localBusinessMetricsServiceProvider =
    FutureProvider<LocalBusinessMetricsService>((ref) async {
      // Survives after [reportsServiceProvider] finishes so [businessIdReader]
      // can safely read the current business id during report queries.
      ref.keepAlive();

      final db = ref.watch(appDatabaseProvider);
      ref.watch(currentBusinessProvider);
      final partyService = await ref.watch(partyServiceProvider.future);
      if (!ref.mounted) throw const AsyncProviderStaleBuild();
      final partyLedgerService = await ref.watch(
        partyLedgerServiceProvider.future,
      );
      if (!ref.mounted) throw const AsyncProviderStaleBuild();
      return LocalBusinessMetricsService(
        db: db,
        businessIdReader: () => ref.read(currentBusinessProvider)?.id ?? '',
        partyLedgerService: partyLedgerService,
        partyService: partyService,
      );
    });
