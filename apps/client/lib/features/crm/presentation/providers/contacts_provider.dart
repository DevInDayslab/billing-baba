import 'dart:async';

import 'package:billing_baba/features/crm/domain/models/contact.dart';
import 'package:billing_baba/features/crm/domain/services/contact_service.dart';
import 'package:billing_baba/features/crm/domain/services/contact_service_types.dart';
import 'package:billing_baba/features/crm/presentation/providers/contacts_selection_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'contacts_provider.g.dart';

const contactsPageSize = 30;

class PaginatedContacts {
  const PaginatedContacts({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.rangeStart,
    required this.rangeEnd,
  });

  final List<Contact> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int rangeStart;
  final int rangeEnd;
}

@Riverpod(keepAlive: true)
class Contacts extends _$Contacts {
  StreamSubscription<List<Contact>>? _subscription;

  @override
  Future<List<Contact>> build() async {
    ref.watch(contactSearchQueryProvider);
    ref.watch(contactFiltersProvider);

    final service = await ref.watch(contactServiceProvider.future);

    final businessId = service.readBusinessId();
    if (businessId == null || businessId.isEmpty) {
      return const [];
    }

    final filters = ref
        .read(contactFiltersProvider.notifier)
        .toServiceFilters()
        .copyWith(searchQuery: ref.read(contactSearchQueryProvider));

    await service.syncFromRemote();

    _subscription?.cancel();
    _subscription = service
        .watchContacts(filters: filters)
        .listen(
          (contacts) {
            state = AsyncData(contacts);
          },
          onError: (Object error, StackTrace stackTrace) {
            state = AsyncError(error, stackTrace);
          },
        );
    ref.onDispose(() => _subscription?.cancel());
    return service.loadContacts(filters: filters);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = await ref.read(contactServiceProvider.future);
      final filters = ref
          .read(contactFiltersProvider.notifier)
          .toServiceFilters()
          .copyWith(searchQuery: ref.read(contactSearchQueryProvider));
      return service.loadContacts(filters: filters);
    });
  }

  Future<Contact> addContact(AddContactServiceInput input) async {
    final service = await ref.read(contactServiceProvider.future);
    return service.addContact(input);
  }

  Future<Contact> updateContact(Contact contact) async {
    final service = await ref.read(contactServiceProvider.future);
    return service.updateContact(contact);
  }

  Future<void> deleteContact(String contactId) async {
    final service = await ref.read(contactServiceProvider.future);
    await service.deleteContact(contactId);
    ref.read(selectedContactIdsProvider.notifier).remove(contactId);
    if (ref.read(selectedContactIdProvider) == contactId) {
      ref.read(selectedContactIdProvider.notifier).selected = null;
    }
  }
}

@riverpod
List<Contact> filteredContactsList(Ref ref) {
  final contactsAsync = ref.watch(contactsProvider);
  return contactsAsync.maybeWhen(
    data: (contacts) => contacts,
    orElse: () => const [],
  );
}

@riverpod
List<Contact> sortedContactsList(Ref ref) {
  final contacts = ref.watch(filteredContactsListProvider);
  final filters = ref.watch(contactFiltersProvider);

  final sorted = List<Contact>.from(contacts);
  if (filters.sortDirection == ContactSortDirection.none) {
    return sorted;
  }

  int compareStrings(String? a, String? b) {
    final left = (a ?? '').toLowerCase();
    final right = (b ?? '').toLowerCase();
    return left.compareTo(right);
  }

  sorted.sort((a, b) {
    final comparison = switch (filters.sortColumn) {
      ContactSortColumn.name => compareStrings(a.name, b.name),
      ContactSortColumn.accountName => compareStrings(
        a.accountName,
        b.accountName,
      ),
      ContactSortColumn.email => compareStrings(a.email, b.email),
      ContactSortColumn.phone => compareStrings(a.phone, b.phone),
      ContactSortColumn.assignedTo => compareStrings(
        a.assignedTo,
        b.assignedTo,
      ),
    };
    return filters.sortDirection == ContactSortDirection.descending
        ? -comparison
        : comparison;
  });

  return sorted;
}

@riverpod
PaginatedContacts paginatedContacts(Ref ref) {
  final contacts = ref.watch(sortedContactsListProvider);
  final filters = ref.watch(contactFiltersProvider);
  final totalItems = contacts.length;
  final totalPages = totalItems == 0
      ? 1
      : (totalItems / contactsPageSize).ceil();
  final currentPage = filters.currentPage.clamp(1, totalPages);
  final start = (currentPage - 1) * contactsPageSize;
  final end = (start + contactsPageSize).clamp(0, totalItems);
  final pageItems = contacts.skip(start).take(contactsPageSize).toList();

  return PaginatedContacts(
    items: pageItems,
    currentPage: currentPage,
    totalPages: totalPages,
    totalItems: totalItems,
    rangeStart: totalItems == 0 ? 0 : start + 1,
    rangeEnd: end,
  );
}

@riverpod
int contactsTotalCount(Ref ref) {
  return ref.watch(paginatedContactsProvider).totalItems;
}
