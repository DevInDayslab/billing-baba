import 'package:billing_baba/features/crm/domain/services/contact_service_types.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'contacts_selection_providers.g.dart';

@Riverpod(keepAlive: true)
class SelectedContactId extends _$SelectedContactId {
  @override
  String? build() => null;

  set selected(String? value) => state = value;
}

@Riverpod(keepAlive: true)
class SelectedContactIds extends _$SelectedContactIds {
  @override
  Set<String> build() => {};

  void toggle(String contactId) {
    final next = Set<String>.from(state);
    if (next.contains(contactId)) {
      next.remove(contactId);
    } else {
      next.add(contactId);
    }
    state = next;
  }

  void toggleAll(Iterable<String> contactIds) {
    final ids = contactIds.toSet();
    if (ids.isEmpty) return;
    if (ids.every(state.contains)) {
      state = Set<String>.from(state)..removeAll(ids);
    } else {
      state = Set<String>.from(state)..addAll(ids);
    }
  }

  void clear() => state = {};

  void remove(String contactId) {
    if (!state.contains(contactId)) return;
    state = Set<String>.from(state)..remove(contactId);
  }
}

enum ContactSortColumn {
  name,
  accountName,
  email,
  phone,
  assignedTo,
}

enum ContactSortDirection {
  none,
  ascending,
  descending,
}

@Riverpod(keepAlive: true)
class ContactSearchQuery extends _$ContactSearchQuery {
  @override
  String build() => '';

  set query(String value) => state = value;
}

@Riverpod(keepAlive: true)
class ContactFilters extends _$ContactFilters {
  @override
  ContactFiltersState build() => const ContactFiltersState();

  void setAccountName(String? accountName) {
    state = state.copyWith(accountName: () => accountName, currentPage: 1);
  }

  void setAssignedTo(String? assignedTo) {
    state = state.copyWith(assignedTo: () => assignedTo, currentPage: 1);
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

  void toggleSort(ContactSortColumn column) {
    if (state.sortColumn != column) {
      state = state.copyWith(
        sortColumn: column,
        sortDirection: ContactSortDirection.ascending,
        currentPage: 1,
      );
      return;
    }

    final nextDirection = switch (state.sortDirection) {
      ContactSortDirection.none => ContactSortDirection.ascending,
      ContactSortDirection.ascending => ContactSortDirection.descending,
      ContactSortDirection.descending => ContactSortDirection.ascending,
    };
    state = state.copyWith(sortDirection: nextDirection, currentPage: 1);
  }

  ContactQueryFilters toServiceFilters() {
    return ContactQueryFilters(
      searchQuery: state.searchQuery,
      accountName: state.accountName,
      assignedTo: state.assignedTo,
      dateFrom: state.dateFrom,
      dateTo: state.dateTo,
    );
  }
}

class ContactFiltersState {
  const ContactFiltersState({
    this.searchQuery = '',
    this.accountName,
    this.assignedTo,
    this.dateFrom,
    this.dateTo,
    this.currentPage = 1,
    this.sortColumn = ContactSortColumn.name,
    this.sortDirection = ContactSortDirection.ascending,
  });

  final String searchQuery;
  final String? accountName;
  final String? assignedTo;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int currentPage;
  final ContactSortColumn sortColumn;
  final ContactSortDirection sortDirection;

  String get ownerLabel => assignedTo ?? 'All Owners';

  String get accountLabel => accountName ?? 'All Accounts';

  ContactFiltersState copyWith({
    String? searchQuery,
    String? Function()? accountName,
    String? Function()? assignedTo,
    DateTime? Function()? dateFrom,
    DateTime? Function()? dateTo,
    int? currentPage,
    ContactSortColumn? sortColumn,
    ContactSortDirection? sortDirection,
  }) {
    return ContactFiltersState(
      searchQuery: searchQuery ?? this.searchQuery,
      accountName: accountName != null ? accountName() : this.accountName,
      assignedTo: assignedTo != null ? assignedTo() : this.assignedTo,
      dateFrom: dateFrom != null ? dateFrom() : this.dateFrom,
      dateTo: dateTo != null ? dateTo() : this.dateTo,
      currentPage: currentPage ?? this.currentPage,
      sortColumn: sortColumn ?? this.sortColumn,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }
}
