class CreateTaxRateRequest {
  const CreateTaxRateRequest({
    required this.name,
    required this.rate,
    this.isDefault = false,
  });

  final String name;
  final String rate;
  final bool isDefault;
}

class UpdateTaxRateRequest {
  const UpdateTaxRateRequest({
    this.name,
    this.rate,
    this.isDefault,
  });

  final String? name;
  final String? rate;
  final bool? isDefault;
}

class TaxRateDto {
  const TaxRateDto({
    required this.id,
    required this.name,
    required this.rate,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String rate;
  final bool isDefault;
  final String createdAt;
  final String updatedAt;
}
