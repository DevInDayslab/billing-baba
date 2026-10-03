import 'dart:async';

import 'package:billing_baba/features/crm/application/deals_selection_providers.dart';
import 'package:billing_baba/features/crm/domain/models/deal.dart';
import 'package:billing_baba/features/crm/domain/services/deal_service.dart';
import 'package:billing_baba/features/crm/domain/services/deal_service_types.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'deals_provider.g.dart';

@Riverpod(keepAlive: true)
class Deals extends _$Deals {
  StreamSubscription<List<Deal>>? _subscription;
  DealService? _service;

  @override
  Future<List<Deal>> build() async {
    ref.watch(dealSearchQueryProvider);
    ref.watch(dealFiltersProvider);

    final service = await ref.watch(dealServiceProvider.future);
    _service = service;

    final businessId = service.readBusinessId();
    if (businessId == null || businessId.isEmpty) {
      return const [];
    }

    final filters = ref
        .read(dealFiltersProvider.notifier)
        .toServiceFilters()
        .copyWith(searchQuery: ref.read(dealSearchQueryProvider));

    // Local-first: paint SQLite immediately, sync in background.
    unawaited(
      service.syncFromRemote().then<void>((_) {}, onError: (_, _) {}),
    );

    unawaited(_subscription?.cancel() ?? Future<void>.value());
    _subscription = service
        .watchDeals(filters: filters)
        .listen(
          (deals) {
            state = AsyncData(deals);
          },
          onError: (Object error, StackTrace stackTrace) {
            state = AsyncError(error, stackTrace);
          },
        );
    ref.onDispose(() => _subscription?.cancel());
    return service.loadDeals(filters: filters);
  }

  Future<void> refresh() async {
    if (!state.hasValue) {
      state = const AsyncLoading();
    }
    state = await AsyncValue.guard(() async {
      final service = await ref.read(dealServiceProvider.future);
      final filters = ref
          .read(dealFiltersProvider.notifier)
          .toServiceFilters()
          .copyWith(searchQuery: ref.read(dealSearchQueryProvider));
      unawaited(service.syncFromRemote());
      return service.loadDeals(filters: filters);
    });
  }

  Future<DealService> _requireService() async {
    final cached = _service;
    if (cached != null) return cached;

    final service = await ref.read(dealServiceProvider.future);
    _service = service;
    return service;
  }

  Future<Deal> addDeal(AddDealServiceInput input) async {
    final service = await _requireService();
    return service.addDeal(input);
  }

  Future<Deal> updateDeal(Deal deal) async {
    final service = await _requireService();
    return service.updateDeal(deal);
  }

  Future<Deal> moveDealToStage(Deal deal, DealStage newStage) async {
    if (deal.stage == newStage) return deal;

    final service = await _requireService();
    final resolved = state.maybeWhen(
      data: (deals) => deals.firstWhere(
        (item) => item.id == deal.id,
        orElse: () => deal,
      ),
      orElse: () => deal,
    );

    return service.moveDealToStage(resolved, newStage);
  }

  Future<void> deleteDeal(String dealId) async {
    final service = await _requireService();
    await service.deleteDeal(dealId);
    ref.read(selectedDealIdsProvider.notifier).remove(dealId);
  }
}

@riverpod
List<Deal> filteredDealsList(Ref ref) {
  final dealsAsync = ref.watch(dealsProvider);
  return dealsAsync.maybeWhen(
    data: (deals) => deals,
    orElse: () => const [],
  );
}

class DealStageSummary {
  const DealStageSummary({
    required this.stage,
    required this.deals,
    required this.totalAmount,
  });

  final DealStage stage;
  final List<Deal> deals;
  final double totalAmount;
}

@riverpod
Map<DealStage, DealStageSummary> dealsByStage(Ref ref) {
  final deals = ref.watch(filteredDealsListProvider);
  final grouped = <DealStage, List<Deal>>{
    for (final stage in DealStageX.pipelineStages) stage: [],
  };

  for (final deal in deals) {
    grouped.putIfAbsent(deal.stage, () => []).add(deal);
  }

  return {
    for (final entry in grouped.entries)
      entry.key: DealStageSummary(
        stage: entry.key,
        deals: entry.value,
        totalAmount: entry.value.fold<double>(
          0,
          (sum, deal) => sum + deal.amount,
        ),
      ),
  };
}
