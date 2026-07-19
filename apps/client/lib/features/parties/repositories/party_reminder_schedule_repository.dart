import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';

enum PartyReminderFrequency { once, weekly, monthly }

/// Local placeholder schedule until a backend reminder scheduler exists.
///
// TODO(backend): Replace local persistence with a scheduling API
/// (e.g. POST /parties/:id/reminder-schedules) so the server can
/// auto-dispatch reminders via NotificationService → Twilio WhatsApp.
class PartyReminderSchedule {
  const PartyReminderSchedule({
    required this.partyId,
    required this.frequency,
    required this.nextReminderAt,
    this.sendCopyToMyself = false,
  });

  factory PartyReminderSchedule.fromJson(Map<String, dynamic> json) {
    return PartyReminderSchedule(
      partyId: json['partyId'] as String,
      frequency: PartyReminderFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => PartyReminderFrequency.once,
      ),
      nextReminderAt: DateTime.parse(json['nextReminderAt'] as String),
      sendCopyToMyself: json['sendCopyToMyself'] as bool? ?? false,
    );
  }

  final String partyId;
  final PartyReminderFrequency frequency;
  final DateTime nextReminderAt;
  final bool sendCopyToMyself;

  Map<String, dynamic> toJson() => {
        'partyId': partyId,
        'frequency': frequency.name,
        'nextReminderAt': nextReminderAt.toIso8601String(),
        'sendCopyToMyself': sendCopyToMyself,
      };
}

/// Local-only reminder schedule store.
///
// TODO(backend): Swap this repository for a remote implementation once
/// party reminder scheduling endpoints are available. Keep the same
/// [PartyReminderSchedule] model so UI/providers stay unchanged.
class PartyReminderScheduleRepository {
  PartyReminderScheduleRepository(this._storage, this._businessId);

  final StorageService _storage;
  final String _businessId;

  String get _key =>
      '${StorageKeys.partyReminderSchedule}_$_businessId.json';

  Future<Map<String, PartyReminderSchedule>> loadAll() async {
    final raw = _storage.read(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final e in json.entries)
          e.key: PartyReminderSchedule.fromJson(
            e.value as Map<String, dynamic>,
          ),
      };
    } on Object {
      return {};
    }
  }

  Future<PartyReminderSchedule?> loadForParty(String partyId) async {
    final all = await loadAll();
    return all[partyId];
  }

  Future<void> save(PartyReminderSchedule schedule) async {
    final all = await loadAll();
    all[schedule.partyId] = schedule;
    await _persist(all);
  }

  Future<void> clear(String partyId) async {
    final all = await loadAll();
    all.remove(partyId);
    await _persist(all);
  }

  Future<void> _persist(Map<String, PartyReminderSchedule> all) async {
    await _storage.write(
      _key,
      jsonEncode({
        for (final e in all.entries) e.key: e.value.toJson(),
      }),
    );
  }
}
