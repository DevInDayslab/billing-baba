import 'package:intl/intl.dart';

class ItemDateFormatOption {
  const ItemDateFormatOption({required this.id, required this.label});

  final String id;
  final String label;
}

abstract final class ItemFieldCatalog {
  static const customFieldCount = 6;

  static const defaultBatchDateFormatId = 'dd/mm/yy';

  static const dateFormatOptions = <ItemDateFormatOption>[
    ItemDateFormatOption(id: 'mm/yy', label: 'mm/yy'),
    ItemDateFormatOption(id: 'dd/mm/yy', label: 'dd/mm/yy'),
    ItemDateFormatOption(id: 'dd-MM-yyyy', label: 'dd-mm-yyyy'),
  ];

  /// Batch tracking (Exp./Mfg. date) — Vyapar shows mm/yy and dd/mm/yy only.
  static const batchDateFormatOptions = <ItemDateFormatOption>[
    ItemDateFormatOption(id: 'mm/yy', label: 'mm/yy'),
    ItemDateFormatOption(id: 'dd/mm/yy', label: 'dd/mm/yy'),
  ];

  static Set<String> get _batchDateFormatIds =>
      batchDateFormatOptions.map((o) => o.id).toSet();

  static String resolveBatchDateFormatId(String? raw) {
    final id = raw?.trim();
    if (id != null && _batchDateFormatIds.contains(id)) return id;
    return defaultBatchDateFormatId;
  }

  static String intlPatternForDateFormatId(String? formatId) {
    return switch (resolveBatchDateFormatId(formatId)) {
      'mm/yy' => 'MM/yy',
      'dd/mm/yy' => 'dd/MM/yy',
      _ => 'dd/MM/yyyy',
    };
  }

  static bool batchDateFormatIsMonthYear(String? formatId) {
    return resolveBatchDateFormatId(formatId) == 'mm/yy';
  }

  static String formatBatchDate(DateTime? date, String? formatId) {
    if (date == null) return '';
    return DateFormat(intlPatternForDateFormatId(formatId)).format(date);
  }

  static DateTime? parseBatchDate(String raw, String? formatId) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    final pattern = intlPatternForDateFormatId(formatId);
    try {
      return DateFormat(pattern).parseStrict(text);
    } on Object {
      return DateTime.tryParse(text);
    }
  }

  static String defaultCustomFieldLabel(int index) =>
      'Custom Field ${index + 1}';

  static String defaultCustomFieldPlaceholder(int index) => switch (index) {
    0 => 'Colour',
    1 => 'Material',
    2 => 'Mfg. Date',
    3 => 'Exp. Date',
    4 => 'Size',
    5 => 'Brand',
    _ => 'Value',
  };

  static ItemCustomFieldSetting defaultCustomField(int index) {
    return ItemCustomFieldSetting(
      enabled: false,
      label: defaultCustomFieldLabel(index),
      placeholder: defaultCustomFieldPlaceholder(index),
      showInPrint: false,
    );
  }

  static List<ItemCustomFieldSetting> defaultCustomFields() {
    return List.generate(customFieldCount, defaultCustomField);
  }
}

class ItemCustomFieldSetting {
  const ItemCustomFieldSetting({
    required this.enabled,
    required this.label,
    required this.placeholder,
    required this.showInPrint,
  });

  final bool enabled;
  final String label;
  final String placeholder;
  final bool showInPrint;

  ItemCustomFieldSetting copyWith({
    bool? enabled,
    String? label,
    String? placeholder,
    bool? showInPrint,
  }) {
    return ItemCustomFieldSetting(
      enabled: enabled ?? this.enabled,
      label: label ?? this.label,
      placeholder: placeholder ?? this.placeholder,
      showInPrint: showInPrint ?? this.showInPrint,
    );
  }

  factory ItemCustomFieldSetting.fromJson(Map<String, dynamic> json, int index) {
    final defaults = ItemFieldCatalog.defaultCustomField(index);
    return ItemCustomFieldSetting(
      enabled: json['enabled'] as bool? ?? defaults.enabled,
      label: json['label'] as String? ?? defaults.label,
      placeholder: json['placeholder'] as String? ?? defaults.placeholder,
      showInPrint: json['showInPrint'] as bool? ?? defaults.showInPrint,
    );
  }

  Map<String, dynamic> toJson(int index) => {
    'index': index,
    'enabled': enabled,
    'label': label,
    'placeholder': placeholder,
    'showInPrint': showInPrint,
  };
}

/// Vyapar-style item field toggles (persisted inside item settings JSON).
class ItemVyaparExtension {
  const ItemVyaparExtension({
    required this.showLowStockDialog,
    required this.directBarcodeScan,
    required this.defaultSecondaryUnitId,
    required this.descriptionFieldLabel,
    required this.mrpEnabled,
    required this.mrpLabel,
    required this.calculateSalePriceFromMrpDisc,
    required this.useMrpForBatchTracking,
    required this.serialTrackingEnabled,
    required this.serialFieldLabel,
    required this.batchTrackingEnabled,
    required this.batchNoEnabled,
    required this.batchNoLabel,
    required this.batchExpDateEnabled,
    required this.batchExpDateFormatId,
    required this.batchExpDateLabel,
    required this.batchMfgDateEnabled,
    required this.batchMfgDateFormatId,
    required this.batchMfgDateLabel,
    required this.batchModelNoEnabled,
    required this.batchModelNoLabel,
    required this.batchSizeEnabled,
    required this.batchSizeLabel,
    required this.customFields,
  });

  factory ItemVyaparExtension.defaults() => ItemVyaparExtension(
    showLowStockDialog: true,
    directBarcodeScan: true,
    defaultSecondaryUnitId: null,
    descriptionFieldLabel: 'Description',
    mrpEnabled: true,
    mrpLabel: 'MRP',
    calculateSalePriceFromMrpDisc: true,
    useMrpForBatchTracking: false,
    serialTrackingEnabled: false,
    serialFieldLabel: 'Serial No.',
    batchTrackingEnabled: false,
    batchNoEnabled: false,
    batchNoLabel: 'Batch No.',
    batchExpDateEnabled: false,
    batchExpDateFormatId: ItemFieldCatalog.batchDateFormatOptions.first.id,
    batchExpDateLabel: 'Exp. Date',
    batchMfgDateEnabled: false,
    batchMfgDateFormatId: ItemFieldCatalog.defaultBatchDateFormatId,
    batchMfgDateLabel: 'Mfg. Date',
    batchModelNoEnabled: false,
    batchModelNoLabel: 'Model No.',
    batchSizeEnabled: false,
    batchSizeLabel: 'Size',
    customFields: ItemFieldCatalog.defaultCustomFields(),
  );

  factory ItemVyaparExtension.fromJson(Map<String, dynamic>? json) {
    final defaults = ItemVyaparExtension.defaults();
    if (json == null) return defaults;

    final fieldsJson = json['customFields'];
    var fields = defaults.customFields;
    if (fieldsJson is List) {
      fields = List.generate(ItemFieldCatalog.customFieldCount, (index) {
        final entry = index < fieldsJson.length ? fieldsJson[index] : null;
        if (entry is Map<String, dynamic>) {
          return ItemCustomFieldSetting.fromJson(entry, index);
        }
        return ItemFieldCatalog.defaultCustomField(index);
      });
    }

    final batchFormatIds = ItemFieldCatalog._batchDateFormatIds;

    return ItemVyaparExtension(
      showLowStockDialog:
          json['showLowStockDialog'] as bool? ?? defaults.showLowStockDialog,
      directBarcodeScan:
          json['directBarcodeScan'] as bool? ??
          json['direct_barcode_scan'] as bool? ??
          defaults.directBarcodeScan,
      defaultSecondaryUnitId: json['defaultSecondaryUnitId'] as String?,
      descriptionFieldLabel:
          json['descriptionFieldLabel'] as String? ??
          defaults.descriptionFieldLabel,
      mrpEnabled: json['mrpEnabled'] as bool? ?? defaults.mrpEnabled,
      mrpLabel: json['mrpLabel'] as String? ?? defaults.mrpLabel,
      calculateSalePriceFromMrpDisc:
          json['calculateSalePriceFromMrpDisc'] as bool? ??
          defaults.calculateSalePriceFromMrpDisc,
      useMrpForBatchTracking:
          json['useMrpForBatchTracking'] as bool? ??
          defaults.useMrpForBatchTracking,
      serialTrackingEnabled:
          json['serialTrackingEnabled'] as bool? ??
          defaults.serialTrackingEnabled,
      serialFieldLabel:
          json['serialFieldLabel'] as String? ?? defaults.serialFieldLabel,
      batchTrackingEnabled:
          json['batchTrackingEnabled'] as bool? ?? defaults.batchTrackingEnabled,
      batchNoEnabled: json['batchNoEnabled'] as bool? ?? defaults.batchNoEnabled,
      batchNoLabel: json['batchNoLabel'] as String? ?? defaults.batchNoLabel,
      batchExpDateEnabled:
          json['batchExpDateEnabled'] as bool? ?? defaults.batchExpDateEnabled,
      batchExpDateFormatId: ItemFieldCatalog.resolveBatchDateFormatId(
        batchFormatIds.contains(json['batchExpDateFormatId'] as String?)
            ? json['batchExpDateFormatId'] as String?
            : null,
      ),
      batchExpDateLabel:
          json['batchExpDateLabel'] as String? ?? defaults.batchExpDateLabel,
      batchMfgDateEnabled:
          json['batchMfgDateEnabled'] as bool? ?? defaults.batchMfgDateEnabled,
      batchMfgDateFormatId: ItemFieldCatalog.resolveBatchDateFormatId(
        batchFormatIds.contains(json['batchMfgDateFormatId'] as String?)
            ? json['batchMfgDateFormatId'] as String?
            : null,
      ),
      batchMfgDateLabel:
          json['batchMfgDateLabel'] as String? ?? defaults.batchMfgDateLabel,
      batchModelNoEnabled:
          json['batchModelNoEnabled'] as bool? ?? defaults.batchModelNoEnabled,
      batchModelNoLabel:
          json['batchModelNoLabel'] as String? ?? defaults.batchModelNoLabel,
      batchSizeEnabled:
          json['batchSizeEnabled'] as bool? ?? defaults.batchSizeEnabled,
      batchSizeLabel: json['batchSizeLabel'] as String? ?? defaults.batchSizeLabel,
      customFields: fields,
    );
  }

  final bool showLowStockDialog;
  final bool directBarcodeScan;
  final String? defaultSecondaryUnitId;
  final String descriptionFieldLabel;
  final bool mrpEnabled;
  final String mrpLabel;
  final bool calculateSalePriceFromMrpDisc;
  final bool useMrpForBatchTracking;
  final bool serialTrackingEnabled;
  final String serialFieldLabel;
  final bool batchTrackingEnabled;
  final bool batchNoEnabled;
  final String batchNoLabel;
  final bool batchExpDateEnabled;
  final String batchExpDateFormatId;
  final String batchExpDateLabel;
  final bool batchMfgDateEnabled;
  final String batchMfgDateFormatId;
  final String batchMfgDateLabel;
  final bool batchModelNoEnabled;
  final String batchModelNoLabel;
  final bool batchSizeEnabled;
  final String batchSizeLabel;
  final List<ItemCustomFieldSetting> customFields;

  Map<String, dynamic> toJson() => {
    'showLowStockDialog': showLowStockDialog,
    'directBarcodeScan': directBarcodeScan,
    'defaultSecondaryUnitId': defaultSecondaryUnitId,
    'descriptionFieldLabel': descriptionFieldLabel,
    'mrpEnabled': mrpEnabled,
    'mrpLabel': mrpLabel,
    'calculateSalePriceFromMrpDisc': calculateSalePriceFromMrpDisc,
    'useMrpForBatchTracking': useMrpForBatchTracking,
    'serialTrackingEnabled': serialTrackingEnabled,
    'serialFieldLabel': serialFieldLabel,
    'batchTrackingEnabled': batchTrackingEnabled,
    'batchNoEnabled': batchNoEnabled,
    'batchNoLabel': batchNoLabel,
    'batchExpDateEnabled': batchExpDateEnabled,
    'batchExpDateFormatId': batchExpDateFormatId,
    'batchExpDateLabel': batchExpDateLabel,
    'batchMfgDateEnabled': batchMfgDateEnabled,
    'batchMfgDateFormatId': batchMfgDateFormatId,
    'batchMfgDateLabel': batchMfgDateLabel,
    'batchModelNoEnabled': batchModelNoEnabled,
    'batchModelNoLabel': batchModelNoLabel,
    'batchSizeEnabled': batchSizeEnabled,
    'batchSizeLabel': batchSizeLabel,
    'customFields': [
      for (var i = 0; i < customFields.length; i++) customFields[i].toJson(i),
    ],
  };

  ItemVyaparExtension copyWith({
    bool? showLowStockDialog,
    bool? directBarcodeScan,
    String? defaultSecondaryUnitId,
    bool clearDefaultSecondaryUnitId = false,
    String? descriptionFieldLabel,
    bool? mrpEnabled,
    String? mrpLabel,
    bool? calculateSalePriceFromMrpDisc,
    bool? useMrpForBatchTracking,
    bool? serialTrackingEnabled,
    String? serialFieldLabel,
    bool? batchTrackingEnabled,
    bool? batchNoEnabled,
    String? batchNoLabel,
    bool? batchExpDateEnabled,
    String? batchExpDateFormatId,
    String? batchExpDateLabel,
    bool? batchMfgDateEnabled,
    String? batchMfgDateFormatId,
    String? batchMfgDateLabel,
    bool? batchModelNoEnabled,
    String? batchModelNoLabel,
    bool? batchSizeEnabled,
    String? batchSizeLabel,
    List<ItemCustomFieldSetting>? customFields,
  }) {
    return ItemVyaparExtension(
      showLowStockDialog: showLowStockDialog ?? this.showLowStockDialog,
      directBarcodeScan: directBarcodeScan ?? this.directBarcodeScan,
      defaultSecondaryUnitId: clearDefaultSecondaryUnitId
          ? null
          : (defaultSecondaryUnitId ?? this.defaultSecondaryUnitId),
      descriptionFieldLabel:
          descriptionFieldLabel ?? this.descriptionFieldLabel,
      mrpEnabled: mrpEnabled ?? this.mrpEnabled,
      mrpLabel: mrpLabel ?? this.mrpLabel,
      calculateSalePriceFromMrpDisc:
          calculateSalePriceFromMrpDisc ?? this.calculateSalePriceFromMrpDisc,
      useMrpForBatchTracking:
          useMrpForBatchTracking ?? this.useMrpForBatchTracking,
      serialTrackingEnabled:
          serialTrackingEnabled ?? this.serialTrackingEnabled,
      serialFieldLabel: serialFieldLabel ?? this.serialFieldLabel,
      batchTrackingEnabled: batchTrackingEnabled ?? this.batchTrackingEnabled,
      batchNoEnabled: batchNoEnabled ?? this.batchNoEnabled,
      batchNoLabel: batchNoLabel ?? this.batchNoLabel,
      batchExpDateEnabled: batchExpDateEnabled ?? this.batchExpDateEnabled,
      batchExpDateFormatId: batchExpDateFormatId ?? this.batchExpDateFormatId,
      batchExpDateLabel: batchExpDateLabel ?? this.batchExpDateLabel,
      batchMfgDateEnabled: batchMfgDateEnabled ?? this.batchMfgDateEnabled,
      batchMfgDateFormatId: batchMfgDateFormatId ?? this.batchMfgDateFormatId,
      batchMfgDateLabel: batchMfgDateLabel ?? this.batchMfgDateLabel,
      batchModelNoEnabled: batchModelNoEnabled ?? this.batchModelNoEnabled,
      batchModelNoLabel: batchModelNoLabel ?? this.batchModelNoLabel,
      batchSizeEnabled: batchSizeEnabled ?? this.batchSizeEnabled,
      batchSizeLabel: batchSizeLabel ?? this.batchSizeLabel,
      customFields: customFields ?? this.customFields,
    );
  }

  ItemVyaparExtension updateCustomField(
    int index,
    ItemCustomFieldSetting field,
  ) {
    final next = List<ItemCustomFieldSetting>.from(customFields);
    while (next.length < ItemFieldCatalog.customFieldCount) {
      next.add(ItemFieldCatalog.defaultCustomField(next.length));
    }
    next[index] = field;
    return copyWith(customFields: next);
  }

  ItemCustomFieldSetting customFieldAt(int index) {
    if (index < 0 || index >= customFields.length) {
      return ItemFieldCatalog.defaultCustomField(index.clamp(0, 5));
    }
    return customFields[index];
  }
}
