import 'dart:io' show Platform;

import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart'
    hide PermissionStatus;

/// Result of requesting device contacts access.
enum DeviceContactPermissionResult {
  granted,
  denied,
  permanentlyDenied,
  unavailable,
}

/// Normalized contact data for pre-filling the party form.
class DeviceContactPrefill {
  const DeviceContactPrefill({
    required this.displayName,
    required this.phones,
    this.email,
    this.address,
  });

  final String displayName;
  final List<String> phones;
  final String? email;
  final String? address;
}

/// Lightweight entry for the contact picker list.
class DeviceContactEntry {
  const DeviceContactEntry({
    required this.id,
    required this.displayName,
    required this.phones,
    this.email,
    this.address,
  });

  final String id;
  final String displayName;
  final List<String> phones;
  final String? email;
  final String? address;

  DeviceContactPrefill toPrefill() => DeviceContactPrefill(
    displayName: displayName,
    phones: phones,
    email: email,
    address: address,
  );
}

/// Reads device contacts for party import (mobile only).
class DeviceContactImportService {
  static const _contactProperties = {
    ContactProperty.name,
    ContactProperty.phone,
    ContactProperty.email,
    ContactProperty.address,
  };

  bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<DeviceContactPermissionResult> requestAccess() async {
    if (!isSupported) return DeviceContactPermissionResult.unavailable;

    final current = await FlutterContacts.permissions.check(
      PermissionType.read,
    );
    if (current == PermissionStatus.granted ||
        current == PermissionStatus.limited) {
      return DeviceContactPermissionResult.granted;
    }
    if (current == PermissionStatus.permanentlyDenied ||
        current == PermissionStatus.restricted) {
      return DeviceContactPermissionResult.permanentlyDenied;
    }

    final status = await FlutterContacts.permissions.request(
      PermissionType.read,
    );
    if (status == PermissionStatus.granted ||
        status == PermissionStatus.limited) {
      return DeviceContactPermissionResult.granted;
    }
    if (status == PermissionStatus.permanentlyDenied ||
        status == PermissionStatus.restricted) {
      return DeviceContactPermissionResult.permanentlyDenied;
    }

    final after = await Permission.contacts.status;
    if (after.isPermanentlyDenied) {
      return DeviceContactPermissionResult.permanentlyDenied;
    }
    return DeviceContactPermissionResult.denied;
  }

  Future<List<DeviceContactEntry>> loadContacts({String? query}) async {
    if (!isSupported) return const [];

    final raw = await FlutterContacts.getAll(properties: _contactProperties);

    final entries = <DeviceContactEntry>[];
    for (final contact in raw) {
      final mapped = _mapContact(contact);
      if (mapped == null) continue;
      entries.add(mapped);
    }

    entries.sort(
      (a, b) => a.displayName.toLowerCase().compareTo(
        b.displayName.toLowerCase(),
      ),
    );

    final q = query?.trim().toLowerCase() ?? '';
    if (q.isEmpty) return entries;

    return entries.where((entry) {
      final haystack = [
        entry.displayName,
        ...entry.phones,
        entry.email ?? '',
        entry.address ?? '',
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  DeviceContactEntry? _mapContact(Contact contact) {
    final name = (contact.displayName ?? '').trim();
    final phones = _normalizePhones(contact.phones.map((p) => p.number));
    if (name.isEmpty && phones.isEmpty) return null;

    final email = contact.emails
        .map((e) => e.address.trim())
        .firstWhere((e) => e.isNotEmpty, orElse: () => '');

    final address = _formatAddress(contact.addresses.firstOrNull);

    return DeviceContactEntry(
      id: contact.id ?? '',
      displayName: name.isNotEmpty ? name : phones.first,
      phones: phones,
      email: email.isEmpty ? null : email,
      address: address,
    );
  }

  List<String> _normalizePhones(Iterable<String> rawPhones) {
    final seen = <String>{};
    final normalized = <String>[];
    for (final raw in rawPhones) {
      final digits = PartyModel.normalizePhone(raw);
      if (digits.length != 10 || seen.contains(digits)) continue;
      seen.add(digits);
      normalized.add(digits);
    }
    return normalized;
  }

  String? _formatAddress(Address? address) {
    if (address == null) return null;
    final formatted = address.formatted?.trim();
    if (formatted != null && formatted.isNotEmpty) return formatted;

    final parts = <String>[
      if ((address.street ?? '').trim().isNotEmpty) address.street!.trim(),
      if ((address.city ?? '').trim().isNotEmpty) address.city!.trim(),
      if ((address.state ?? '').trim().isNotEmpty) address.state!.trim(),
      if ((address.postalCode ?? '').trim().isNotEmpty)
        address.postalCode!.trim(),
      if ((address.country ?? '').trim().isNotEmpty &&
          address.country!.trim().toLowerCase() != 'india')
        address.country!.trim(),
    ];
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }
}

final deviceContactImportServiceProvider = Provider<DeviceContactImportService>(
  (ref) => DeviceContactImportService(),
);
