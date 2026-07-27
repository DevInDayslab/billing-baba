import 'package:billing_baba/core/sync/models/sync_queue_enums.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/crm/data/sources/contact_local_source.dart';
import 'package:billing_baba/features/crm/data/sources/contact_remote_source.dart';
import 'package:billing_baba/features/crm/domain/models/contact.dart';
import 'package:billing_baba/features/crm/domain/models/contact_activity.dart';

class ContactRepository {
  ContactRepository({
    required ContactLocalSource local,
    required ContactRemoteSource remote,
    required SyncQueue syncQueue,
  })  : _local = local,
        _remote = remote,
        _syncQueue = syncQueue;

  final ContactLocalSource _local;
  final ContactRemoteSource _remote;
  final SyncQueue _syncQueue;

  ContactRemoteSource get remote => _remote;

  ContactLocalSource get local => _local;

  String? readBusinessId() => _local.readBusinessId();

  Stream<List<Contact>> watchContacts(String businessId) =>
      _local.watchContacts(businessId);

  Future<List<Contact>> getContacts(String businessId) =>
      _local.getContacts(businessId);

  Future<Contact?> getContactById(String businessId, String contactId) =>
      _local.getContactById(businessId, contactId);

  Stream<List<ContactActivity>> watchActivities(
    String businessId,
    String contactId,
  ) =>
      _local.watchActivities(businessId, contactId);

  Future<Contact> saveContact(
    Contact contact, {
    required String operation,
  }) async {
    await _local.upsertContact(contact);
    await _enqueue(
      businessId: contact.businessId,
      entityType: 'contact',
      entityId: contact.id,
      operation: operation,
      payload: contact.toJson(),
    );
    return contact;
  }

  Future<ContactActivity> saveActivity(
    ContactActivity activity, {
    required String operation,
  }) async {
    await _local.upsertActivity(activity);
    await _enqueue(
      businessId: activity.businessId,
      entityType: 'contact_activity',
      entityId: activity.id,
      operation: operation,
      payload: activity.toJson(),
    );
    return activity;
  }

  Future<void> _enqueue({
    required String businessId,
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  }) {
    return _syncQueue.enqueueRowMutation(
      businessId: businessId,
      entityType: entityType,
      entityId: entityId,
      operation: SyncQueueOperation.fromWire(operation),
      payload: payload,
    );
  }
}
