import 'dart:convert';

import 'package:billing_baba/features/crm/data/sources/contact_local_source.dart';
import 'package:billing_baba/features/crm/data/sources/contact_remote_source.dart';
import 'package:billing_baba/features/crm/domain/models/contact.dart';
import 'package:billing_baba/features/crm/domain/models/contact_activity.dart';

class ContactRepository {
  ContactRepository({
    required this._local,
    required this._remote,
  });

  final ContactLocalSource _local;
  final ContactRemoteSource _remote;

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
  ) => _local.watchActivities(businessId, contactId);

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
      createdAt: contact.updatedAt.toUtc().toIso8601String(),
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
      createdAt: activity.updatedAt.toUtc().toIso8601String(),
    );
    return activity;
  }

  Future<void> _enqueue({
    required String businessId,
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
    required String createdAt,
  }) async {
    await _local.enqueueSyncOperation(
      businessId: businessId,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payload: jsonEncode(payload),
      createdAt: createdAt,
    );
  }
}
