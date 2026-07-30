import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/crm/domain/models/contact.dart';
import 'package:billing_baba/features/crm/domain/models/contact_activity.dart';
import 'package:drift/drift.dart';

class ContactLocalSource {
  ContactLocalSource(this._db, this._storage);

  final AppDatabase _db;
  final StorageService _storage;

  String? readBusinessId() => _storage.read(StorageKeys.lastOpenedBusinessId);

  Stream<List<Contact>> watchContacts(String businessId) {
    final query = _db.select(_db.contacts)
      ..where(
        (row) =>
            row.businessId.equals(businessId) & row.isDeleted.equals(false),
      )
      ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]);

    return query.watch().map((rows) => rows.map(_contactFromRow).toList());
  }

  Future<List<Contact>> getContacts(String businessId) async {
    final rows =
        await (_db.select(_db.contacts)
              ..where(
                (row) =>
                    row.businessId.equals(businessId) &
                    row.isDeleted.equals(false),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
            .get();
    return rows.map(_contactFromRow).toList();
  }

  Future<Contact?> getContactById(String businessId, String contactId) async {
    final row =
        await (_db.select(_db.contacts)..where(
              (tbl) =>
                  tbl.id.equals(contactId) &
                  tbl.businessId.equals(businessId) &
                  tbl.isDeleted.equals(false),
            ))
            .getSingleOrNull();
    return row == null ? null : _contactFromRow(row);
  }

  Stream<List<ContactActivity>> watchActivities(
    String businessId,
    String contactId,
  ) {
    final query = _db.select(_db.contactActivities)
      ..where(
        (row) =>
            row.businessId.equals(businessId) &
            row.contactId.equals(contactId) &
            row.isDeleted.equals(false),
      )
      ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]);

    return query.watch().map((rows) => rows.map(_activityFromRow).toList());
  }

  Future<void> upsertContact(Contact contact) async {
    await _db
        .into(_db.contacts)
        .insertOnConflictUpdate(_contactToCompanion(contact));
  }

  Future<void> upsertActivity(ContactActivity activity) async {
    await _db
        .into(_db.contactActivities)
        .insertOnConflictUpdate(_activityToCompanion(activity));
  }

  Contact _contactFromRow(ContactTableData row) {
    return Contact(
      id: row.id,
      businessId: row.businessId,
      name: row.name,
      firstName: row.firstName,
      lastName: row.lastName,
      salutation: row.salutation,
      accountName: row.accountName,
      phone: row.phone,
      email: row.email,
      assignedTo: row.assignedTo,
      title: row.title,
      description: row.description,
      syncVersion: row.syncVersion,
      isDeleted: row.isDeleted,
      updatedAt: DateTime.parse(row.updatedAt),
      deletedAt: row.deletedAt == null
          ? null
          : DateTime.tryParse(row.deletedAt!),
      deviceId: row.deviceId,
      syncStatus: row.syncStatus,
      createdAt: DateTime.parse(row.createdAt),
    );
  }

  ContactActivity _activityFromRow(ContactActivityTableData row) {
    return ContactActivity(
      id: row.id,
      contactId: row.contactId,
      businessId: row.businessId,
      type: ContactActivityTypeX.fromWire(row.type),
      notes: row.notes,
      addedBy: row.addedBy,
      syncVersion: row.syncVersion,
      isDeleted: row.isDeleted,
      updatedAt: DateTime.parse(row.updatedAt),
      deletedAt: row.deletedAt == null
          ? null
          : DateTime.tryParse(row.deletedAt!),
      deviceId: row.deviceId,
      syncStatus: row.syncStatus,
      createdAt: DateTime.parse(row.createdAt),
    );
  }

  ContactsCompanion _contactToCompanion(Contact contact) {
    return ContactsCompanion.insert(
      id: contact.id,
      businessId: contact.businessId,
      name: contact.name,
      firstName: Value(contact.firstName),
      lastName: Value(contact.lastName),
      salutation: Value(contact.salutation),
      accountName: Value(contact.accountName),
      phone: Value(contact.phone),
      email: Value(contact.email),
      assignedTo: Value(contact.assignedTo),
      title: Value(contact.title),
      description: Value(contact.description),
      syncVersion: Value(contact.syncVersion),
      isDeleted: Value(contact.isDeleted),
      updatedAt: contact.updatedAt.toUtc().toIso8601String(),
      deletedAt: Value(contact.deletedAt?.toUtc().toIso8601String()),
      deviceId: Value(contact.deviceId),
      syncStatus: Value(contact.syncStatus),
      createdAt: contact.createdAt.toUtc().toIso8601String(),
    );
  }

  ContactActivitiesCompanion _activityToCompanion(ContactActivity activity) {
    return ContactActivitiesCompanion.insert(
      id: activity.id,
      contactId: activity.contactId,
      businessId: activity.businessId,
      type: activity.type.wireValue,
      notes: Value(activity.notes),
      addedBy: Value(activity.addedBy),
      syncVersion: Value(activity.syncVersion),
      isDeleted: Value(activity.isDeleted),
      updatedAt: activity.updatedAt.toUtc().toIso8601String(),
      deletedAt: Value(activity.deletedAt?.toUtc().toIso8601String()),
      deviceId: Value(activity.deviceId),
      syncStatus: Value(activity.syncStatus),
      createdAt: activity.createdAt.toUtc().toIso8601String(),
    );
  }
}
