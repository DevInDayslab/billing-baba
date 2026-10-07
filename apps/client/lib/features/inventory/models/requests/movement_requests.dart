class CreateMovementRequest {
  const CreateMovementRequest({
    required this.itemId,
    required this.godownId,
    required this.movementType,
    required this.quantityDelta,
    this.costPerUnit,
    this.referenceId,
    this.referenceType,
    this.notes,
    this.unit,
    this.adjustmentAt,
  });

  final String itemId;
  final String godownId;
  final String movementType;
  final String quantityDelta;
  final String? costPerUnit;
  final String? referenceId;
  final String? referenceType;
  final String? notes;
  /// Display unit short name (e.g. Pcs, Pkt) for ledger display.
  final String? unit;
  /// Local adjustment timestamp; defaults to now when omitted.
  final DateTime? adjustmentAt;

  Map<String, dynamic> toJson() => {
    'item_id': itemId,
    'godown_id': godownId,
    'movement_type': movementType,
    'quantity_delta': quantityDelta,
    if (costPerUnit != null) 'cost_per_unit': costPerUnit,
    if (referenceId != null) 'reference_id': referenceId,
    if (referenceType != null) 'reference_type': referenceType,
    if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
  };
}
