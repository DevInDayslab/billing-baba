import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/dashboard/application/local_business_metrics_service.dart';
import 'package:billing_baba/features/parties/application/party_ledger_service.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localBusinessMetricsServiceProvider =
    FutureProvider<LocalBusinessMetricsService>((ref) async {
      final db = ref.watch(appDatabaseProvider);
      ref.watch(currentBusinessProvider);
      final partyService = await ref.watch(partyServiceProvider.future);
      final partyLedgerService = await ref.watch(partyLedgerServiceProvider.future);
      return LocalBusinessMetricsService(
        db: db,
        businessIdReader: () => ref.read(currentBusinessProvider)?.id ?? '',
        partyLedgerService: partyLedgerService,
        partyService: partyService,
      );
    });
