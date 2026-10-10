typedef PartySettingsUpdater = PartySettings Function(PartySettings current);

/// Value type for party additional fields (field 4 can be a date).
enum PartyAdditionalFieldValueKind {
  text,
  date,
}

/// Date display pattern when [PartyAdditionalFieldValueKind.date] is selected.
class PartyAdditionalFieldDateFormatOption {
  const PartyAdditionalFieldDateFormatOption({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;
}

abstract final class PartyAdditionalFieldCatalog {
  static const fieldCount = 4;

  static const dateFormatOptions = <PartyAdditionalFieldDateFormatOption>[
    PartyAdditionalFieldDateFormatOption(id: 'dd/MM/yy', label: 'dd/mm/yy'),
    PartyAdditionalFieldDateFormatOption(id: 'dd-MM-yyyy', label: 'dd-mm-yyyy'),
    PartyAdditionalFieldDateFormatOption(id: 'MM/dd/yyyy', label: 'mm/dd/yyyy'),
  ];

  static String defaultLabelForIndex(int index) => 'Additional Field ${index + 1}';

  static PartyAdditionalFieldConfig defaultField(int index) {
    return PartyAdditionalFieldConfig(
      enabled: false,
      label: defaultLabelForIndex(index),
      showInPrint: false,
      valueKind: index == 3
          ? PartyAdditionalFieldValueKind.date
          : PartyAdditionalFieldValueKind.text,
      dateFormatId: dateFormatOptions.first.id,
    );
  }

  static List<PartyAdditionalFieldConfig> defaultFields() {
    return List.generate(fieldCount, defaultField);
  }
}

class PartyAdditionalFieldConfig {
  const PartyAdditionalFieldConfig({
    required this.enabled,
    required this.label,
    required this.showInPrint,
    required this.valueKind,
    required this.dateFormatId,
  });

  final bool enabled;
  final String label;
  final bool showInPrint;
  final PartyAdditionalFieldValueKind valueKind;
  final String dateFormatId;

  PartyAdditionalFieldConfig copyWith({
    bool? enabled,
    String? label,
    bool? showInPrint,
    PartyAdditionalFieldValueKind? valueKind,
    String? dateFormatId,
  }) {
    return PartyAdditionalFieldConfig(
      enabled: enabled ?? this.enabled,
      label: label ?? this.label,
      showInPrint: showInPrint ?? this.showInPrint,
      valueKind: valueKind ?? this.valueKind,
      dateFormatId: dateFormatId ?? this.dateFormatId,
    );
  }

  factory PartyAdditionalFieldConfig.fromJson(Map<String, dynamic> json) {
    final index = (json['index'] as num?)?.toInt();
    final defaults = PartyAdditionalFieldCatalog.defaultField(
      index != null ? index.clamp(0, 3) : 0,
    );
    final kindRaw = json['valueKind'] as String?;
    final valueKind = kindRaw == PartyAdditionalFieldValueKind.date.name
        ? PartyAdditionalFieldValueKind.date
        : PartyAdditionalFieldValueKind.text;
    final formatId = json['dateFormatId'] as String? ?? defaults.dateFormatId;
    final knownIds = PartyAdditionalFieldCatalog.dateFormatOptions
        .map((o) => o.id)
        .toSet();
    return PartyAdditionalFieldConfig(
      enabled: json['enabled'] as bool? ?? defaults.enabled,
      label: json['label'] as String? ?? defaults.label,
      showInPrint: json['showInPrint'] as bool? ?? defaults.showInPrint,
      valueKind: valueKind,
      dateFormatId: knownIds.contains(formatId)
          ? formatId
          : PartyAdditionalFieldCatalog.dateFormatOptions.first.id,
    );
  }

  Map<String, dynamic> toJson(int index) => {
    'index': index,
    'enabled': enabled,
    'label': label,
    'showInPrint': showInPrint,
    'valueKind': valueKind.name,
    'dateFormatId': dateFormatId,
  };
}

/// Business-scoped party feature preferences (device-local persistence).
class PartySettings {
  const PartySettings({
    required this.partyGroupingEnabled,
    required this.shippingAddressEnabled,
    required this.printShippingAddressEnabled,
    required this.managePartyStatusEnabled,
    required this.paymentReminderEnabled,
    required this.paymentReminderDueDays,
    required this.reminderAdditionalMessage,
    required this.loyaltyPointsEnabled,
    required this.additionalFields,
  });

  factory PartySettings.defaults() => PartySettings(
    partyGroupingEnabled: true,
    shippingAddressEnabled: true,
    printShippingAddressEnabled: true,
    managePartyStatusEnabled: true,
    paymentReminderEnabled: true,
    paymentReminderDueDays: 15,
    reminderAdditionalMessage: '',
    loyaltyPointsEnabled: false,
    additionalFields: PartyAdditionalFieldCatalog.defaultFields(),
  );

  factory PartySettings.fromJson(Map<String, dynamic> json) {
    final defaults = PartySettings.defaults();
    final fieldsJson = json['additionalFields'];
    var fields = defaults.additionalFields;
    if (fieldsJson is List) {
      fields = List.generate(PartyAdditionalFieldCatalog.fieldCount, (index) {
        final entry = index < fieldsJson.length ? fieldsJson[index] : null;
        if (entry is Map<String, dynamic>) {
          return PartyAdditionalFieldConfig.fromJson(entry);
        }
        return PartyAdditionalFieldCatalog.defaultField(index);
      });
    }
    return PartySettings(
      partyGroupingEnabled:
          json['partyGroupingEnabled'] as bool? ?? defaults.partyGroupingEnabled,
      shippingAddressEnabled:
          json['shippingAddressEnabled'] as bool? ??
          defaults.shippingAddressEnabled,
      printShippingAddressEnabled:
          json['printShippingAddressEnabled'] as bool? ??
          defaults.printShippingAddressEnabled,
      managePartyStatusEnabled:
          json['managePartyStatusEnabled'] as bool? ??
          defaults.managePartyStatusEnabled,
      paymentReminderEnabled:
          json['paymentReminderEnabled'] as bool? ??
          defaults.paymentReminderEnabled,
      paymentReminderDueDays: _clampReminderDays(
        json['paymentReminderDueDays'],
        defaults.paymentReminderDueDays,
      ),
      reminderAdditionalMessage:
          json['reminderAdditionalMessage'] as String? ??
          defaults.reminderAdditionalMessage,
      loyaltyPointsEnabled:
          json['loyaltyPointsEnabled'] as bool? ?? defaults.loyaltyPointsEnabled,
      additionalFields: fields,
    );
  }

  final bool partyGroupingEnabled;
  final bool shippingAddressEnabled;
  final bool printShippingAddressEnabled;
  final bool managePartyStatusEnabled;
  final bool paymentReminderEnabled;
  final int paymentReminderDueDays;
  final String reminderAdditionalMessage;
  final bool loyaltyPointsEnabled;
  final List<PartyAdditionalFieldConfig> additionalFields;

  PartySettings copyWith({
    bool? partyGroupingEnabled,
    bool? shippingAddressEnabled,
    bool? printShippingAddressEnabled,
    bool? managePartyStatusEnabled,
    bool? paymentReminderEnabled,
    int? paymentReminderDueDays,
    String? reminderAdditionalMessage,
    bool? loyaltyPointsEnabled,
    List<PartyAdditionalFieldConfig>? additionalFields,
  }) {
    return PartySettings(
      partyGroupingEnabled: partyGroupingEnabled ?? this.partyGroupingEnabled,
      shippingAddressEnabled:
          shippingAddressEnabled ?? this.shippingAddressEnabled,
      printShippingAddressEnabled:
          printShippingAddressEnabled ?? this.printShippingAddressEnabled,
      managePartyStatusEnabled:
          managePartyStatusEnabled ?? this.managePartyStatusEnabled,
      paymentReminderEnabled:
          paymentReminderEnabled ?? this.paymentReminderEnabled,
      paymentReminderDueDays:
          paymentReminderDueDays ?? this.paymentReminderDueDays,
      reminderAdditionalMessage:
          reminderAdditionalMessage ?? this.reminderAdditionalMessage,
      loyaltyPointsEnabled: loyaltyPointsEnabled ?? this.loyaltyPointsEnabled,
      additionalFields: additionalFields ?? this.additionalFields,
    );
  }

  Map<String, dynamic> toJson() => {
    'partyGroupingEnabled': partyGroupingEnabled,
    'shippingAddressEnabled': shippingAddressEnabled,
    'printShippingAddressEnabled': printShippingAddressEnabled,
    'managePartyStatusEnabled': managePartyStatusEnabled,
    'paymentReminderEnabled': paymentReminderEnabled,
    'paymentReminderDueDays': paymentReminderDueDays,
    'reminderAdditionalMessage': reminderAdditionalMessage,
    'loyaltyPointsEnabled': loyaltyPointsEnabled,
    'additionalFields': [
      for (var i = 0; i < additionalFields.length; i++)
        additionalFields[i].toJson(i),
    ],
  };

  PartyAdditionalFieldConfig fieldAt(int index) {
    if (index < 0 || index >= additionalFields.length) {
      return PartyAdditionalFieldCatalog.defaultField(index.clamp(0, 3));
    }
    return additionalFields[index];
  }

  PartySettings updateField(int index, PartyAdditionalFieldConfig field) {
    final next = List<PartyAdditionalFieldConfig>.from(additionalFields);
    while (next.length < PartyAdditionalFieldCatalog.fieldCount) {
      next.add(PartyAdditionalFieldCatalog.defaultField(next.length));
    }
    next[index] = field;
    return copyWith(additionalFields: next);
  }
}

/// Fixed reminder template lines (placeholders resolved when sending).
int _clampReminderDays(Object? raw, int fallback) {
  final parsed = raw is num ? raw.toInt() : int.tryParse('$raw');
  if (parsed == null) return fallback;
  return parsed.clamp(1, 365);
}

abstract final class PartyPaymentReminderMessageTemplate {
  static const partyNameToken = '[Party Name]';
  static const amountToken = '[Amount]';
  static const businessNameToken = '[Business Name]';

  static const greetingLine = 'Dear, $partyNameToken';
  static const pendingLine =
      'Your payment of $amountToken is pending with $businessNameToken';
  static const closingLine =
      'If you have already made the payment, kindly ignore this message.';
}
