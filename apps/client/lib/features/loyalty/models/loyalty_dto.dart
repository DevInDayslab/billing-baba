class PartyLoyaltyBalanceDto {
  const PartyLoyaltyBalanceDto({
    required this.partyId,
    required this.pointsEarned,
    required this.pointsAvailable,
  });

  factory PartyLoyaltyBalanceDto.fromJson(Map<String, dynamic> json) {
    return PartyLoyaltyBalanceDto(
      partyId: json['party_id'] as String? ?? '',
      pointsEarned: json['points_earned'] as String? ?? '0',
      pointsAvailable: json['points_available'] as String? ?? '0',
    );
  }

  final String partyId;
  final String pointsEarned;
  final String pointsAvailable;

  double get availablePoints =>
      double.tryParse(pointsAvailable) ?? 0;

  double get earnedPointsValue =>
      double.tryParse(pointsEarned) ?? 0;
}

class SaleLoyaltyResultDto {
  const SaleLoyaltyResultDto({
    required this.earnedPoints,
    required this.redeemedPoints,
    required this.pointsAvailable,
  });

  factory SaleLoyaltyResultDto.fromJson(Map<String, dynamic> json) {
    return SaleLoyaltyResultDto(
      earnedPoints: json['earned_points'] as String? ?? '0',
      redeemedPoints: json['redeemed_points'] as String? ?? '0',
      pointsAvailable: json['points_available'] as String? ?? '0',
    );
  }

  final String earnedPoints;
  final String redeemedPoints;
  final String pointsAvailable;

  int get earnedPointsInt => (double.tryParse(earnedPoints) ?? 0).round();

  double get availablePoints => double.tryParse(pointsAvailable) ?? 0;
}

class FinalizeSalesDocumentResult {
  const FinalizeSalesDocumentResult({
    this.loyalty,
  });

  factory FinalizeSalesDocumentResult.fromJson(Map<String, dynamic> json) {
    final loyaltyJson = json['loyalty'];
    return FinalizeSalesDocumentResult(
      loyalty: loyaltyJson is Map<String, dynamic>
          ? SaleLoyaltyResultDto.fromJson(loyaltyJson)
          : null,
    );
  }

  final SaleLoyaltyResultDto? loyalty;
}
