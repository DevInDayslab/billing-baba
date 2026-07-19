import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/settings/models/transaction_message_settings.dart';

class TransactionMessageSettingsRepository {
  TransactionMessageSettingsRepository(this._storage, this._businessId);

  final StorageService _storage;
  final String _businessId;

  String get _key =>
      '${StorageKeys.transactionMessageSettings}_$_businessId.json';

  Future<TransactionMessageSettings> load() async {
    final raw = _storage.read(_key);
    if (raw == null || raw.isEmpty) {
      return TransactionMessageSettings.defaults();
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return _fromJson(json);
    } on Object {
      return TransactionMessageSettings.defaults();
    }
  }

  Future<void> save(TransactionMessageSettings settings) async {
    await _storage.write(_key, jsonEncode(_toJson(settings)));
  }

  Map<String, dynamic> _toJson(TransactionMessageSettings s) {
    return {
      'sendToParty': s.sendToParty,
      'sendTransactionUpdate': s.sendTransactionUpdate,
      'sendCopyToMyself': s.sendCopyToMyself,
      'includeCurrentBalance': s.includeCurrentBalance,
      'includeInvoiceLink': s.includeInvoiceLink,
      'includeFooter': s.includeFooter,
      'autoSend': {
        for (final e in s.autoSend.entries) e.key.name: e.value,
      },
      'templates': {
        for (final e in s.templates.entries)
          e.key.name: {'body': e.value.body, 'footer': e.value.footer},
      },
    };
  }

  TransactionMessageSettings _fromJson(Map<String, dynamic> json) {
    final defaults = TransactionMessageSettings.defaults();
    final autoSendRaw = json['autoSend'] as Map<String, dynamic>? ?? {};
    final templatesRaw = json['templates'] as Map<String, dynamic>? ?? {};

    final autoSend = <TransactionMessageType, bool>{
      for (final type in TransactionMessageType.values)
        type: autoSendRaw[type.name] as bool? ??
            defaults.autoSend[type] ??
            false,
    };

    final templates = <TransactionMessageType, MessageTemplate>{
      for (final type in TransactionMessageType.values)
        type: () {
          final t = templatesRaw[type.name] as Map<String, dynamic>?;
          if (t == null) return defaults.templateFor(type);
          return MessageTemplate(
            body: t['body'] as String? ?? defaults.templateFor(type).body,
            footer: t['footer'] as String? ?? defaults.templateFor(type).footer,
          );
        }(),
    };

    return TransactionMessageSettings(
      sendToParty: json['sendToParty'] as bool? ?? defaults.sendToParty,
      sendTransactionUpdate: json['sendTransactionUpdate'] as bool? ??
          defaults.sendTransactionUpdate,
      sendCopyToMyself:
          json['sendCopyToMyself'] as bool? ?? defaults.sendCopyToMyself,
      includeCurrentBalance: json['includeCurrentBalance'] as bool? ??
          defaults.includeCurrentBalance,
      includeInvoiceLink:
          json['includeInvoiceLink'] as bool? ?? defaults.includeInvoiceLink,
      includeFooter: json['includeFooter'] as bool? ?? defaults.includeFooter,
      autoSend: autoSend,
      templates: templates,
    );
  }
}
