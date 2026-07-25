import 'dart:async';

import 'package:billing_baba/features/crm/domain/models/lead.dart';
import 'package:billing_baba/features/crm/domain/services/lead_service.dart';
import 'package:billing_baba/features/crm/domain/services/lead_service_types.dart';
import 'package:billing_baba/features/crm/application/leads_selection_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'leads_provider.g.dart';

const leadsPageSize = 30;

class PaginatedLeads {
  const PaginatedLeads({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.rangeStart,
    required this.rangeEnd,
  });

  final List<Lead> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int rangeStart;
  final int rangeEnd;
}

@Riverpod(keepAlive: true)
class Leads extends _$Leads {
  StreamSubscription<List<Lead>>? _subscription;

  int get totalCount {
    final current = state;
    return current.maybeWhen(data: (leads) => leads.length, orElse: () => 0);
  }

  @override
  Future<List<Lead>> build() async {
    try {
      ref.watch(leadSearchQueryProvider);
      ref.watch(leadFiltersProvider);
      final service = await ref.watch(leadServiceProvider.future);
      final businessId = service.readBusinessId();
      if (businessId == null || businessId.isEmpty) {
        return const [];
      }
      final filters = ref
          .read(leadFiltersProvider.notifier)
          .toServiceFilters()
          .copyWith(searchQuery: ref.read(leadSearchQueryProvider));
      await service.syncFromRemote();
      _subscription?.cancel();
      _subscription = service
          .watchLeads(filters: filters)
          .listen(
            (leads) {
              state = AsyncData(leads);
            },
            onError: (Object error, StackTrace stackTrace) {
              debugPrint('🔴 LEADS STREAM ERROR: $error\n$stackTrace');
              state = AsyncError(error, stackTrace);
            },
          );
      ref.onDispose(() => _subscription?.cancel());
      return service.loadLeads(filters: filters);
    } catch (e, st) {
      debugPrint('🔴 LEADS PROVIDER BUILD ERROR: $e\n$st');
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = await ref.read(leadServiceProvider.future);
      final filters = ref
          .read(leadFiltersProvider.notifier)
          .toServiceFilters()
          .copyWith(searchQuery: ref.read(leadSearchQueryProvider));
      return service.loadLeads(filters: filters);
    });
  }

  Future<Lead> addLead(AddLeadInput input) async {
    final service = await ref.read(leadServiceProvider.future);
    final lead = await service.addLead(input);
    return lead;
  }

  Future<Lead> updateLead(Lead lead) async {
    final service = await ref.read(leadServiceProvider.future);
    return service.updateLead(lead);
  }

  Future<void> deleteLead(String leadId) async {
    final service = await ref.read(leadServiceProvider.future);
    await service.deleteLead(leadId);
    ref.read(selectedLeadIdsProvider.notifier).remove(leadId);
    if (ref.read(selectedLeadIdProvider) == leadId) {
      ref.read(selectedLeadIdProvider.notifier).selected = null;
    }
  }

  List<Lead> filterLeads(List<Lead> leads) {
    final service = ref.read(leadServiceProvider).requireValue;
    final filters = ref
        .read(leadFiltersProvider.notifier)
        .toServiceFilters()
        .copyWith(searchQuery: ref.read(leadSearchQueryProvider));
    return service.filterLeads(leads, filters);
  }
}

@riverpod
List<Lead> filteredLeadsList(Ref ref) {
  final leadsAsync = ref.watch(leadsProvider);
  return leadsAsync.maybeWhen(
    data: (leads) => leads,
    orElse: () => const [],
  );
}

@riverpod
List<Lead> sortedLeadsList(Ref ref) {
  final leads = ref.watch(filteredLeadsListProvider);
  final filters = ref.watch(leadFiltersProvider);

  final sorted = List<Lead>.from(leads);
  if (filters.sortDirection == LeadSortDirection.none) {
    return sorted;
  }

  int compareStrings(String? a, String? b) {
    final left = (a ?? '').toLowerCase();
    final right = (b ?? '').toLowerCase();
    return left.compareTo(right);
  }

  sorted.sort((a, b) {
    final comparison = switch (filters.sortColumn) {
      LeadSortColumn.name => compareStrings(a.name, b.name),
      LeadSortColumn.company => compareStrings(a.company, b.company),
      LeadSortColumn.email => compareStrings(a.email, b.email),
      LeadSortColumn.phone => compareStrings(a.phone, b.phone),
      LeadSortColumn.leadSource => compareStrings(
        a.leadSource?.label,
        b.leadSource?.label,
      ),
    };
    return filters.sortDirection == LeadSortDirection.descending
        ? -comparison
        : comparison;
  });

  return sorted;
}

@riverpod
PaginatedLeads paginatedLeads(Ref ref) {
  final leads = ref.watch(sortedLeadsListProvider);
  final filters = ref.watch(leadFiltersProvider);
  final totalItems = leads.length;
  final totalPages = totalItems == 0 ? 1 : (totalItems / leadsPageSize).ceil();
  final currentPage = filters.currentPage.clamp(1, totalPages);
  final start = (currentPage - 1) * leadsPageSize;
  final end = (start + leadsPageSize).clamp(0, totalItems);
  final pageItems = leads.skip(start).take(leadsPageSize).toList();

  return PaginatedLeads(
    items: pageItems,
    currentPage: currentPage,
    totalPages: totalPages,
    totalItems: totalItems,
    rangeStart: totalItems == 0 ? 0 : start + 1,
    rangeEnd: end,
  );
}

@riverpod
int leadsTotalCount(Ref ref) {
  return ref.watch(paginatedLeadsProvider).totalItems;
}
