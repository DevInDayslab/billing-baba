import 'dart:async';

import 'package:billing_baba/features/parties/application/parties_selection_providers.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/party_list_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Entry-point helpers for the Parties feature.
abstract final class PartiesNavigation {
  /// Sidebar / primary nav: show every party (no receivable/payable drill-down).
  static void prepareSidebarEntry(WidgetRef ref) {
    ref.read(partyListFilterProvider.notifier).filter = PartyListFilter.all;
    ref.read(partySearchQueryProvider.notifier).query = '';
    ref.read(partyBackendSearchProvider.notifier).query = '';
    unawaited(
      ref.read(partyListProvider.notifier).refresh(
        filter: PartyListFilter.all,
        searchQuery: '',
      ),
    );
    unawaited(
      ref.read(partyServiceProvider.future).then(
        (service) => service.rememberListFilter(PartyListFilter.all),
      ),
    );
  }

  /// Dashboard receivable/payable drill-down — must not be cleared by page init.
  static bool isDashboardBalanceFilter(PartyListFilter filter) {
    return filter == PartyListFilter.toReceive ||
        filter == PartyListFilter.toPay;
  }

  /// Filters restored from storage — receivable/payable are dashboard-only.
  static PartyListFilter filterForPageRestore(PartyListFilter? remembered) {
    if (remembered == null) return PartyListFilter.all;
    return switch (remembered) {
      PartyListFilter.toReceive || PartyListFilter.toPay => PartyListFilter.all,
      _ => remembered,
    };
  }
}
