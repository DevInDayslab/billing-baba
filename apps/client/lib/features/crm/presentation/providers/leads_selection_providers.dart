import 'package:billing_baba/features/crm/domain/models/lead.dart';
import 'package:billing_baba/features/crm/domain/services/lead_service_types.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'leads_selection_providers.g.dart';

@Riverpod(keepAlive: true)
class SelectedLeadId extends _$SelectedLeadId {
  @override
  String? build() => null;

  set selected(String? value) => state = value;
}

@Riverpod(keepAlive: true)
class SelectedLeadIds extends _$SelectedLeadIds {
  @override
  Set<String> build() => {};

  void toggle(String leadId) {
    final next = Set<String>.from(state);
    if (next.contains(leadId)) {
      next.remove(leadId);
    } else {
      next.add(leadId);
    }
    state = next;
  }

  void toggleAll(Iterable<String> leadIds) {
    final ids = leadIds.toSet();
    if (ids.isEmpty) return;
    if (ids.every(state.contains)) {
      state = Set<String>.from(state)..removeAll(ids);
    } else {
      state = Set<String>.from(state)..addAll(ids);
    }
  }

  void clear() => state = {};

  void remove(String leadId) {
    if (!state.contains(leadId)) return;
    state = Set<String>.from(state)..remove(leadId);
  }
}

enum LeadSortColumn {
  name,
  company,
  email,
  phone,
  leadSource,
}

enum LeadSortDirection {
  none,
  ascending,
  descending,
}

@Riverpod(keepAlive: true)
class LeadSearchQuery extends _$LeadSearchQuery {
  @override
  String build() => '';

  set query(String value) => state = value;
}

@Riverpod(keepAlive: true)
class LeadFilters extends _$LeadFilters {
  @override
  LeadFiltersState build() => const LeadFiltersState();

  void setStatus(LeadStatus? status) {
    state = state.copyWith(status: () => status, currentPage: 1);
  }

  void setLeadSource(LeadSource? source) {
    state = state.copyWith(leadSource: () => source, currentPage: 1);
  }

  void setDateRange(DateTimeRange? range) {
    state = state.copyWith(
      dateFrom: () => range?.start,
      dateTo: () => range?.end,
      currentPage: 1,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, currentPage: 1);
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void toggleSort(LeadSortColumn column) {
    if (state.sortColumn != column) {
      state = state.copyWith(
        sortColumn: column,
        sortDirection: LeadSortDirection.ascending,
        currentPage: 1,
      );
      return;
    }

    final nextDirection = switch (state.sortDirection) {
      LeadSortDirection.none => LeadSortDirection.ascending,
      LeadSortDirection.ascending => LeadSortDirection.descending,
      LeadSortDirection.descending => LeadSortDirection.ascending,
    };
    state = state.copyWith(sortDirection: nextDirection, currentPage: 1);
  }

  LeadQueryFilters toServiceFilters() {
    return LeadQueryFilters(
      searchQuery: state.searchQuery,
      status: state.status,
      leadSource: state.leadSource,
      dateFrom: state.dateFrom,
      dateTo: state.dateTo,
    );
  }
}

class LeadFiltersState {
  const LeadFiltersState({
    this.searchQuery = '',
    this.status,
    this.leadSource,
    this.dateFrom,
    this.dateTo,
    this.currentPage = 1,
    this.sortColumn = LeadSortColumn.name,
    this.sortDirection = LeadSortDirection.ascending,
  });

  final String searchQuery;
  final LeadStatus? status;
  final LeadSource? leadSource;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int currentPage;
  final LeadSortColumn sortColumn;
  final LeadSortDirection sortDirection;

  String get statusLabel => status?.label ?? 'All Status';

  String get leadSourceLabel => leadSource?.label ?? 'All Source';

  LeadFiltersState copyWith({
    String? searchQuery,
    LeadStatus? Function()? status,
    LeadSource? Function()? leadSource,
    DateTime? Function()? dateFrom,
    DateTime? Function()? dateTo,
    int? currentPage,
    LeadSortColumn? sortColumn,
    LeadSortDirection? sortDirection,
  }) {
    return LeadFiltersState(
      searchQuery: searchQuery ?? this.searchQuery,
      status: status != null ? status() : this.status,
      leadSource: leadSource != null ? leadSource() : this.leadSource,
      dateFrom: dateFrom != null ? dateFrom() : this.dateFrom,
      dateTo: dateTo != null ? dateTo() : this.dateTo,
      currentPage: currentPage ?? this.currentPage,
      sortColumn: sortColumn ?? this.sortColumn,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }
}
