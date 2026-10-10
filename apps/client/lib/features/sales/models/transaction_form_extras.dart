/// How invoice totals are rounded when round-off is enabled.
enum RoundOffMode {
  nearest,
  downTo,
  upTo;

  String get label => switch (this) {
    RoundOffMode.nearest => 'Nearest',
    RoundOffMode.downTo => 'Down To',
    RoundOffMode.upTo => 'Up To',
  };

  static const valuesInOrder = [
    RoundOffMode.nearest,
    RoundOffMode.downTo,
    RoundOffMode.upTo,
  ];

  static RoundOffMode fromStorage(String? value) {
    return RoundOffMode.valuesInOrder.firstWhere(
      (mode) => mode.name == value,
      orElse: () => RoundOffMode.nearest,
    );
  }
}

/// Targets shown in the round-off "To" dropdown.
const roundOffTargetValues = [1, 10, 50, 100, 1000];

class PaymentTermSetting {
  const PaymentTermSetting({
    required this.id,
    required this.name,
    required this.days,
    required this.isDefault,
    this.locked = false,
  });

  final String id;
  final String name;
  final int days;
  final bool isDefault;
  final bool locked;

  PaymentTermSetting copyWith({
    String? name,
    int? days,
    bool? isDefault,
  }) {
    return PaymentTermSetting(
      id: id,
      name: name ?? this.name,
      days: days ?? this.days,
      isDefault: isDefault ?? this.isDefault,
      locked: locked,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'days': days,
    'isDefault': isDefault,
    'locked': locked,
  };

  factory PaymentTermSetting.fromJson(Map<String, dynamic> json) {
    return PaymentTermSetting(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      days: (json['days'] as num?)?.toInt() ?? 0,
      isDefault: json['isDefault'] as bool? ?? false,
      locked: json['locked'] as bool? ?? false,
    );
  }
}

class TransportFieldSetting {
  const TransportFieldSetting({
    required this.id,
    required this.label,
    required this.enabled,
    required this.showInPrint,
  });

  final String id;
  final String label;
  final bool enabled;
  final bool showInPrint;

  TransportFieldSetting copyWith({
    String? label,
    bool? enabled,
    bool? showInPrint,
  }) {
    return TransportFieldSetting(
      id: id,
      label: label ?? this.label,
      enabled: enabled ?? this.enabled,
      showInPrint: showInPrint ?? this.showInPrint,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'enabled': enabled,
    'showInPrint': showInPrint,
  };

  factory TransportFieldSetting.fromJson(Map<String, dynamic> json) {
    return TransportFieldSetting(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? false,
      showInPrint: json['showInPrint'] as bool? ?? true,
    );
  }
}

class AdditionalChargeSetting {
  const AdditionalChargeSetting({
    required this.id,
    required this.name,
    required this.defaultSac,
    required this.taxRateId,
    required this.selected,
    required this.taxEnabled,
  });

  final String id;
  final String name;
  final String defaultSac;
  final String taxRateId;
  final bool selected;
  final bool taxEnabled;

  AdditionalChargeSetting copyWith({
    String? name,
    String? defaultSac,
    String? taxRateId,
    bool? selected,
    bool? taxEnabled,
  }) {
    return AdditionalChargeSetting(
      id: id,
      name: name ?? this.name,
      defaultSac: defaultSac ?? this.defaultSac,
      taxRateId: taxRateId ?? this.taxRateId,
      selected: selected ?? this.selected,
      taxEnabled: taxEnabled ?? this.taxEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'defaultSac': defaultSac,
    'taxRateId': taxRateId,
    'selected': selected,
    'taxEnabled': taxEnabled,
  };

  factory AdditionalChargeSetting.fromJson(Map<String, dynamic> json) {
    return AdditionalChargeSetting(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      defaultSac: json['defaultSac'] as String? ?? '',
      taxRateId: json['taxRateId'] as String? ?? '',
      selected: json['selected'] as bool? ?? false,
      taxEnabled: json['taxEnabled'] as bool? ?? false,
    );
  }
}

class TransactionFormExtras {
  const TransactionFormExtras({
    required this.roundOffMode,
    required this.paymentTerms,
    required this.transportFields,
    required this.additionalCharges,
    required this.customPrefixes,
  });

  factory TransactionFormExtras.defaults() {
    return TransactionFormExtras(
      roundOffMode: RoundOffMode.nearest,
      paymentTerms: defaultPaymentTerms(),
      transportFields: defaultTransportFields(),
      additionalCharges: defaultAdditionalCharges(),
      customPrefixes: const [],
    );
  }

  final RoundOffMode roundOffMode;
  final List<PaymentTermSetting> paymentTerms;
  final List<TransportFieldSetting> transportFields;
  final List<AdditionalChargeSetting> additionalCharges;
  final List<String> customPrefixes;

  TransactionFormExtras copyWith({
    RoundOffMode? roundOffMode,
    List<PaymentTermSetting>? paymentTerms,
    List<TransportFieldSetting>? transportFields,
    List<AdditionalChargeSetting>? additionalCharges,
    List<String>? customPrefixes,
  }) {
    return TransactionFormExtras(
      roundOffMode: roundOffMode ?? this.roundOffMode,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      transportFields: transportFields ?? this.transportFields,
      additionalCharges: additionalCharges ?? this.additionalCharges,
      customPrefixes: customPrefixes ?? this.customPrefixes,
    );
  }

  Map<String, dynamic> toJson() => {
    'roundOffMode': roundOffMode.name,
    'paymentTerms': paymentTerms.map((e) => e.toJson()).toList(),
    'transportFields': transportFields.map((e) => e.toJson()).toList(),
    'additionalCharges': additionalCharges.map((e) => e.toJson()).toList(),
    'customPrefixes': customPrefixes,
  };

  factory TransactionFormExtras.fromJson(Map<String, dynamic>? json) {
    final defaults = TransactionFormExtras.defaults();
    if (json == null) return defaults;
    return TransactionFormExtras(
      roundOffMode: RoundOffMode.fromStorage(json['roundOffMode'] as String?),
      paymentTerms: _list(
        json['paymentTerms'],
        PaymentTermSetting.fromJson,
        defaults.paymentTerms,
      ),
      transportFields: _list(
        json['transportFields'],
        TransportFieldSetting.fromJson,
        defaults.transportFields,
      ),
      additionalCharges: _list(
        json['additionalCharges'],
        AdditionalChargeSetting.fromJson,
        defaults.additionalCharges,
      ),
      customPrefixes: (json['customPrefixes'] as List?)
              ?.map((e) => '$e'.trim())
              .where((e) => e.isNotEmpty)
              .toList() ??
          defaults.customPrefixes,
    );
  }

  static List<T> _list<T>(
    Object? raw,
    T Function(Map<String, dynamic>) decode,
    List<T> fallback,
  ) {
    if (raw is! List || raw.isEmpty) return fallback;
    final parsed = <T>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        parsed.add(decode(item));
      } else if (item is Map) {
        parsed.add(decode(Map<String, dynamic>.from(item)));
      }
    }
    return parsed.isEmpty ? fallback : parsed;
  }

  static List<PaymentTermSetting> defaultPaymentTerms() => const [
    PaymentTermSetting(
      id: 'due_on_receipt',
      name: 'Due on Receipt',
      days: 0,
      isDefault: true,
      locked: true,
    ),
    PaymentTermSetting(id: 'net_15', name: 'Net 15', days: 15, isDefault: false),
    PaymentTermSetting(id: 'net_30', name: 'Net 30', days: 30, isDefault: false),
    PaymentTermSetting(id: 'net_45', name: 'Net 45', days: 45, isDefault: false),
    PaymentTermSetting(id: 'net_60', name: 'Net 60', days: 60, isDefault: false),
  ];

  static List<TransportFieldSetting> defaultTransportFields() => const [
    TransportFieldSetting(
      id: 'transport_name',
      label: 'Transport Name',
      enabled: false,
      showInPrint: true,
    ),
    TransportFieldSetting(
      id: 'vehicle_number',
      label: 'Vehicle Number',
      enabled: false,
      showInPrint: true,
    ),
    TransportFieldSetting(
      id: 'delivery_date',
      label: 'Delivery Date',
      enabled: false,
      showInPrint: true,
    ),
    TransportFieldSetting(
      id: 'delivery_location',
      label: 'Delivery Location',
      enabled: false,
      showInPrint: true,
    ),
    TransportFieldSetting(
      id: 'field_5',
      label: 'Field 5',
      enabled: false,
      showInPrint: true,
    ),
  ];

  static List<AdditionalChargeSetting> defaultAdditionalCharges() => const [
    AdditionalChargeSetting(
      id: 'charge_1',
      name: 'Shipping',
      defaultSac: '',
      taxRateId: '',
      selected: false,
      taxEnabled: false,
    ),
    AdditionalChargeSetting(
      id: 'charge_2',
      name: 'Packaging',
      defaultSac: '',
      taxRateId: '',
      selected: false,
      taxEnabled: false,
    ),
    AdditionalChargeSetting(
      id: 'charge_3',
      name: 'Adjustment',
      defaultSac: '',
      taxRateId: '',
      selected: false,
      taxEnabled: false,
    ),
  ];
}
