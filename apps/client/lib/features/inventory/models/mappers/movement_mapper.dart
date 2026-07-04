import 'package:billing_baba/features/inventory/models/dto/movement_dto.dart';
import 'package:billing_baba/features/inventory/models/product_transaction_model.dart';

abstract final class MovementMapper {
  static ProductTransaction toProductTransaction(MovementDto dto) {
    final qty = double.tryParse(dto.quantityDelta) ?? 0;
    final inboundTypes = {'purchase', 'sales_return', 'opening'};
    return ProductTransaction(
      id: dto.id,
      itemId: dto.itemId,
      typeLabel: _formatMovementType(dto.movementType),
      invoiceRefNo: dto.referenceId ?? '-',
      partyName: '-',
      date: DateTime.tryParse(dto.createdAt) ?? DateTime.now(),
      quantity: qty.abs(),
      pricePerUnit: double.tryParse(dto.costPerUnit ?? '') ?? 0,
      status: dto.referenceType ?? 'Completed',
      isInbound: inboundTypes.contains(dto.movementType),
    );
  }

  static String _formatMovementType(String type) {
    return type
        .split('_')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }
}
