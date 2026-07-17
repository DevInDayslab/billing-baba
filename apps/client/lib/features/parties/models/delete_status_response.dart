import 'package:billing_baba/features/parties/models/delete_status_dto.dart';

/// Domain model for party delete eligibility.
class DeleteStatusResponse {
  const DeleteStatusResponse({
    required this.canDelete,
    this.references,
  });

  factory DeleteStatusResponse.fromDto(DeleteStatusDto dto) {
    return DeleteStatusResponse(
      canDelete: dto.canDelete,
      references: dto.references == null
          ? null
          : PartyDeleteReferences.fromDto(dto.references!),
    );
  }

  final bool canDelete;
  final PartyDeleteReferences? references;
}

class PartyDeleteReferences {
  const PartyDeleteReferences({
    required this.sales,
    required this.purchases,
    required this.payments,
    required this.salesReturns,
    required this.purchaseReturns,
  });

  factory PartyDeleteReferences.fromDto(PartyDeleteReferencesDto dto) {
    return PartyDeleteReferences(
      sales: dto.sales,
      purchases: dto.purchases,
      payments: dto.payments,
      salesReturns: dto.salesReturns,
      purchaseReturns: dto.purchaseReturns,
    );
  }

  final int sales;
  final int purchases;
  final int payments;
  final int salesReturns;
  final int purchaseReturns;

  /// Linked record lines to show in the inactive dialog (counts > 0 only).
  List<PartyDeleteReferenceLine> get visibleLines {
    final lines = <PartyDeleteReferenceLine>[
      if (sales > 0) PartyDeleteReferenceLine(label: 'Sales', count: sales),
      if (purchases > 0)
        PartyDeleteReferenceLine(label: 'Purchases', count: purchases),
      if (payments > 0)
        PartyDeleteReferenceLine(label: 'Payments', count: payments),
      if (salesReturns > 0)
        PartyDeleteReferenceLine(label: 'Sales Returns', count: salesReturns),
      if (purchaseReturns > 0)
        PartyDeleteReferenceLine(
          label: 'Purchase Returns',
          count: purchaseReturns,
        ),
    ];
    return lines;
  }
}

class PartyDeleteReferenceLine {
  const PartyDeleteReferenceLine({
    required this.label,
    required this.count,
  });

  final String label;
  final int count;
}
