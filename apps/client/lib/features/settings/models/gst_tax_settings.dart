enum CompositeBusinessCategory {
  manufacturing,
  traderGoods,
  restaurant;

  String get label => switch (this) {
    CompositeBusinessCategory.manufacturing => 'Manufacturing',
    CompositeBusinessCategory.traderGoods => 'Trader (Goods)',
    CompositeBusinessCategory.restaurant => 'Restaurant',
  };

  static CompositeBusinessCategory fromStorage(String? value) {
    return CompositeBusinessCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => CompositeBusinessCategory.traderGoods,
    );
  }
}

class GstTaxSettings {
  const GstTaxSettings({
    required this.enableGst,
    required this.enableHsnSac,
    required this.additionalCessOnItem,
    required this.reverseCharge,
    required this.enablePlaceOfSupply,
    required this.compositeScheme,
    required this.compositeCategory,
    required this.enableTcs,
    required this.enableTds,
  });

  factory GstTaxSettings.defaults() => const GstTaxSettings(
    enableGst: true,
    enableHsnSac: true,
    additionalCessOnItem: false,
    reverseCharge: false,
    enablePlaceOfSupply: true,
    compositeScheme: false,
    compositeCategory: CompositeBusinessCategory.traderGoods,
    enableTcs: false,
    enableTds: false,
  );

  factory GstTaxSettings.fromJson(Map<String, dynamic> json) {
    final defaults = GstTaxSettings.defaults();
    return GstTaxSettings(
      enableGst: json['enableGst'] as bool? ?? defaults.enableGst,
      enableHsnSac: json['enableHsnSac'] as bool? ?? defaults.enableHsnSac,
      additionalCessOnItem:
          json['additionalCessOnItem'] as bool? ??
          defaults.additionalCessOnItem,
      reverseCharge: json['reverseCharge'] as bool? ?? defaults.reverseCharge,
      enablePlaceOfSupply:
          json['enablePlaceOfSupply'] as bool? ??
          defaults.enablePlaceOfSupply,
      compositeScheme:
          json['compositeScheme'] as bool? ?? defaults.compositeScheme,
      compositeCategory: CompositeBusinessCategory.fromStorage(
        json['compositeCategory'] as String?,
      ),
      enableTcs: json['enableTcs'] as bool? ?? defaults.enableTcs,
      enableTds: json['enableTds'] as bool? ?? defaults.enableTds,
    );
  }

  final bool enableGst;
  final bool enableHsnSac;
  final bool additionalCessOnItem;
  final bool reverseCharge;
  final bool enablePlaceOfSupply;
  final bool compositeScheme;
  final CompositeBusinessCategory compositeCategory;
  final bool enableTcs;
  final bool enableTds;

  Map<String, dynamic> toJson() => {
    'enableGst': enableGst,
    'enableHsnSac': enableHsnSac,
    'additionalCessOnItem': additionalCessOnItem,
    'reverseCharge': reverseCharge,
    'enablePlaceOfSupply': enablePlaceOfSupply,
    'compositeScheme': compositeScheme,
    'compositeCategory': compositeCategory.name,
    'enableTcs': enableTcs,
    'enableTds': enableTds,
  };

  GstTaxSettings copyWith({
    bool? enableGst,
    bool? enableHsnSac,
    bool? additionalCessOnItem,
    bool? reverseCharge,
    bool? enablePlaceOfSupply,
    bool? compositeScheme,
    CompositeBusinessCategory? compositeCategory,
    bool? enableTcs,
    bool? enableTds,
  }) {
    return GstTaxSettings(
      enableGst: enableGst ?? this.enableGst,
      enableHsnSac: enableHsnSac ?? this.enableHsnSac,
      additionalCessOnItem: additionalCessOnItem ?? this.additionalCessOnItem,
      reverseCharge: reverseCharge ?? this.reverseCharge,
      enablePlaceOfSupply: enablePlaceOfSupply ?? this.enablePlaceOfSupply,
      compositeScheme: compositeScheme ?? this.compositeScheme,
      compositeCategory: compositeCategory ?? this.compositeCategory,
      enableTcs: enableTcs ?? this.enableTcs,
      enableTds: enableTds ?? this.enableTds,
    );
  }
}
