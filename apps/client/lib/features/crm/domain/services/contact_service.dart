import 'dart:async';

import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/crm/data/repositories/contact_repository.dart';
import 'package:billing_baba/features/crm/data/sources/contact_local_source.dart';
import 'package:billing_baba/features/crm/data/sources/contact_remote_source.dart';
import 'package:billing_baba/features/crm/domain/models/contact.dart';
import 'package:billing_baba/features/crm/domain/services/contact_service_types.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'contact_service.g.dart';

const _uuid = Uuid();

@Riverpod(keepAlive: true)
Future<ContactService> contactService(Ref ref) async {
  final db = ref.watch(appDatabaseProvider);
  final storage = await ref.watch(storageServiceProvider.future);
  final api = await ref.watch(apiClientProvider.future);
  final repository = ContactRepository(
    local: ContactLocalSource(db, storage),
    remote: ContactRemoteSource(api.dio),
  );
  return ContactService(repository);
}

class ContactService {
  ContactService(this._repository);

  final ContactRepository _repository;

  /// Returns the current business ID without throwing.
  /// Returns null if no business is selected.
  String? readBusinessId() => _repository.readBusinessId();

  String _requireBusinessId() {
    final businessId = _repository.readBusinessId();
    if (businessId == null || businessId.isEmpty) {
      throw const ContactBusinessNotSelectedException();
    }
    return businessId;
  }

  Stream<List<Contact>> watchContacts({
    ContactQueryFilters filters = const ContactQueryFilters(),
  }) {
    final businessId = _requireBusinessId();
    return _repository
        .watchContacts(businessId)
        .map((contacts) => filterContacts(contacts, filters));
  }

  Future<List<Contact>> loadContacts({
    ContactQueryFilters filters = const ContactQueryFilters(),
  }) async {
    final businessId = _requireBusinessId();
    final contacts = await _repository.getContacts(businessId);
    return filterContacts(contacts, filters);
  }

  Future<void> syncFromRemote() async {
    final businessId = _requireBusinessId();
    try {
      final remoteContacts = await _repository.remote.listContacts(limit: 100);
      for (final contact in remoteContacts) {
        if (contact.businessId == businessId) {
          await _repository.local.upsertContact(contact);
        }
      }
    } on Object {
      // Silent fallback to local Drift data
    }
  }

  Stream<ContactWithActivities?> watchContactDetail(String contactId) {
    final businessId = _requireBusinessId();
    final refreshTrigger = Stream<void>.multi((controller) {
      final contactSub = _repository
          .watchContacts(businessId)
          .listen(
            (_) => controller.add(null),
            onError: controller.addError,
          );
      final activitySub = _repository
          .watchActivities(businessId, contactId)
          .listen(
            (_) => controller.add(null),
            onError: controller.addError,
          );
      controller.onCancel = () async {
        await contactSub.cancel();
        await activitySub.cancel();
      };
    });

    return refreshTrigger.asyncMap((_) async {
      final contact = await _repository.getContactById(businessId, contactId);
      if (contact == null) return null;
      final activities = await _repository
          .watchActivities(businessId, contactId)
          .first;
      return ContactWithActivities(contact: contact, activities: activities);
    });
  }

  Future<ContactWithActivities?> getContactDetail(String contactId) async {
    final businessId = _requireBusinessId();
    final contact = await _repository.getContactById(businessId, contactId);
    if (contact == null) return null;
    final activities = await _repository
        .watchActivities(businessId, contactId)
        .first;
    return ContactWithActivities(contact: contact, activities: activities);
  }

  List<Contact> filterContacts(
    List<Contact> contacts,
    ContactQueryFilters filters,
  ) {
    final query = filters.searchQuery.trim().toLowerCase();
    return contacts.where((contact) {
      if (filters.accountName != null &&
          contact.accountName != filters.accountName) {
        return false;
      }
      if (filters.assignedTo != null &&
          contact.assignedTo != filters.assignedTo) {
        return false;
      }
      if (filters.dateFrom != null &&
          contact.createdAt.isBefore(_startOfDay(filters.dateFrom!))) {
        return false;
      }
      if (filters.dateTo != null &&
          contact.createdAt.isAfter(_endOfDay(filters.dateTo!))) {
        return false;
      }
      if (query.isEmpty) return true;
      return contact.name.toLowerCase().contains(query) ||
          (contact.accountName?.toLowerCase().contains(query) ?? false) ||
          (contact.email?.toLowerCase().contains(query) ?? false) ||
          (contact.phone?.contains(query) ?? false);
    }).toList();
  }

  Future<Contact> addContact(AddContactServiceInput input) async {
    _validateAddInput(input);
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();

    final contact = Contact(
      id: _uuid.v4(),
      businessId: businessId,
      name: input.name.trim(),
      firstName: _nullableTrim(input.firstName),
      lastName: _nullableTrim(input.lastName),
      salutation: _nullableTrim(input.salutation),
      accountName: _nullableTrim(input.accountName),
      phone: input.phone.trim(),
      email: _nullableTrim(input.email),
      assignedTo: _nullableTrim(input.assignedTo),
      title: _nullableTrim(input.title),
      description: _nullableTrim(input.description),
      updatedAt: now,
      createdAt: now,
    );

    return _repository.saveContact(contact, operation: 'create');
  }

  Future<Contact> updateContact(Contact contact) async {
    final businessId = _requireBusinessId();
    if (contact.businessId != businessId) {
      throw const ContactValidationException(
        'Contact does not belong to this business',
      );
    }
    final updated = contact.copyWith(
      updatedAt: DateTime.now().toUtc(),
      syncStatus: 'pending',
    );
    return _repository.saveContact(updated, operation: 'update');
  }

  Future<void> deleteContact(String contactId) async {
    final businessId = _requireBusinessId();
    final existing = await _repository.getContactById(businessId, contactId);
    if (existing == null) return;

    final now = DateTime.now().toUtc();
    final deleted = existing.copyWith(
      isDeleted: true,
      deletedAt: now,
      updatedAt: now,
      syncStatus: 'pending',
    );
    await _repository.saveContact(deleted, operation: 'delete');
  }

  void _validateAddInput(AddContactServiceInput input) {
    if (input.name.trim().isEmpty) {
      throw const ContactValidationException('Contact name is required');
    }
    if (input.phone.trim().isEmpty) {
      throw const ContactValidationException('Phone number is required');
    }
  }

  static String? _nullableTrim(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  static DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
}
