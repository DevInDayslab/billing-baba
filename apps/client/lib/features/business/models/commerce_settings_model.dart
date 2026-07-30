class CommerceSettingsModel {
  const CommerceSettingsModel({
    required this.pricingTierLabels,
    this.defaultInvoiceTaxRate,
  });

  factory CommerceSettingsModel.fromJson(Map<String, dynamic> json) {
    final rawLabels = json['pricing_tier_labels'];
    final labels = <String, String>{};
    if (rawLabels is Map) {
      for (final entry in rawLabels.entries) {
        final key = entry.key?.toString();
        final value = entry.value?.toString();
        if (key != null && value != null && value.isNotEmpty) {
          labels[key] = value;
        }
      }
    }

    return CommerceSettingsModel(
      pricingTierLabels: labels,
      defaultInvoiceTaxRate: json['default_invoice_tax_rate']?.toString(),
    );
  }

  final Map<String, String> pricingTierLabels;
  final String? defaultInvoiceTaxRate;

  Map<String, dynamic> toUpdateJson({
    Map<String, String>? pricingTierLabels,
    double? defaultInvoiceTaxRate,
    bool clearDefaultInvoiceTaxRate = false,
  }) {
    return {
      'pricing_tier_labels': ?pricingTierLabels,
      if (clearDefaultInvoiceTaxRate) 'default_invoice_tax_rate': null,
      if (!clearDefaultInvoiceTaxRate && defaultInvoiceTaxRate != null)
        'default_invoice_tax_rate': defaultInvoiceTaxRate,
    };
  }

  double? get defaultInvoiceTaxPercent =>
      double.tryParse(defaultInvoiceTaxRate ?? '');
}
