/// API response for GET /parties/:id/delete-status.
class DeleteStatusDto {
  const DeleteStatusDto({
    required this.canDelete,
    this.references,
  });

  factory DeleteStatusDto.fromJson(Map<String, dynamic> json) {
    final referencesJson = json['references'];
    return DeleteStatusDto(
      canDelete: json['canDelete'] as bool? ?? false,
      references: referencesJson is Map<String, dynamic>
          ? PartyDeleteReferencesDto.fromJson(referencesJson)
          : null,
    );
  }

  final bool canDelete;
  final PartyDeleteReferencesDto? references;
}

class PartyDeleteReferencesDto {
  const PartyDeleteReferencesDto({
    required this.sales,
    required this.purchases,
    required this.payments,
    required this.salesReturns,
    required this.purchaseReturns,
  });

  factory PartyDeleteReferencesDto.fromJson(Map<String, dynamic> json) {
    return PartyDeleteReferencesDto(
      sales: _readCount(json['sales']),
      purchases: _readCount(json['purchases']),
      payments: _readCount(json['payments']),
      salesReturns: _readCount(json['salesReturns']),
      purchaseReturns: _readCount(json['purchaseReturns']),
    );
  }

  final int sales;
  final int purchases;
  final int payments;
  final int salesReturns;
  final int purchaseReturns;

  static int _readCount(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }
}

enum PartyDeleteAction { deleted, deactivated }

class PartyDeleteResultDto {
  const PartyDeleteResultDto({required this.action});

  factory PartyDeleteResultDto.fromJson(Map<String, dynamic> json) {
    final action = json['action'] as String?;
    return PartyDeleteResultDto(
      action: action == 'deactivated'
          ? PartyDeleteAction.deactivated
          : PartyDeleteAction.deleted,
    );
  }

  final PartyDeleteAction action;
}
