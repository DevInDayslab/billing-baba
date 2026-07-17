import 'package:billing_baba/core/utils/date_time_utils.dart';
import 'package:billing_baba/features/inventory/models/dto/movement_dto.dart';
import 'package:billing_baba/features/inventory/models/product_transaction_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_stock_utils.dart';

abstract final class MovementMapper {
  static final _uuidPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  static ProductTransaction toProductTransaction(MovementDto dto) {
    final qty = double.tryParse(dto.quantityDelta) ?? 0;
    final isInbound = _isInboundMovement(dto.movementType, qty);
    final documentLabel = _documentLabel(dto.movementType);
    final referenceNo = _formatReferenceNo(
      dto.referenceNumber,
      dto.referenceId,
      dto.referenceType,
    );
    final partyName = dto.partyName?.trim();

    return ProductTransaction(
      id: dto.id,
      itemId: dto.itemId,
      typeLabel: documentLabel,
      documentLabel: documentLabel,
      transactionType: _transactionTypeLabel(dto.movementType),
      movementType: dto.movementType,
      invoiceRefNo: referenceNo,
      referenceNo: referenceNo,
      partyName: partyName == null || partyName.isEmpty
          ? inventoryEmDash
          : partyName,
      date: DateTimeUtils.parseApiDateTime(dto.createdAt),
      quantity: qty.abs(),
      unit: dto.unit,
      pricePerUnit: double.tryParse(dto.costPerUnit ?? '') ?? 0,
      status: 'Completed',
      isInbound: isInbound,
      godownName: dto.godownName,
    );
  }

  static bool _isInboundMovement(String movementType, double quantityDelta) {
    return switch (movementType) {
      'purchase' || 'sales_return' || 'opening' => true,
      'sale' || 'purchase_return' || 'challan' => false,
      'adjustment' => quantityDelta >= 0,
      _ => quantityDelta >= 0,
    };
  }

  static String _documentLabel(String movementType) {
    return switch (movementType) {
      'opening' => 'Opening Stock',
      'purchase' => 'Purchase Bill',
      'sale' => 'Sale Invoice',
      'sales_return' => 'Sales Return',
      'purchase_return' => 'Purchase Return',
      'challan' => 'Delivery Challan',
      'adjustment' => 'Stock Adjustment',
      'transfer' => 'Transfer',
      'damage' => 'Damage',
      'manual_adjustment' => 'Manual Adjustment',
      'sales_document' => 'Sale Invoice',
      'purchase_document' => 'Purchase Bill',
      _ => _humanizeToken(movementType),
    };
  }

  static String _transactionTypeLabel(String movementType) {
    return switch (movementType) {
      'opening' => 'Opening',
      'purchase' => 'Purchase',
      'sale' => 'Sale',
      'sales_return' => 'Return',
      'purchase_return' => 'Return',
      'challan' => 'Challan',
      'adjustment' => 'Adjustment',
      'transfer' => 'Transfer',
      'damage' => 'Damage',
      'manual_adjustment' => 'Adjustment',
      'sales_document' => 'Sale',
      'purchase_document' => 'Purchase',
      _ => _humanizeToken(movementType),
    };
  }

  static String _formatReferenceNo(
    String? referenceNumber,
    String? referenceId,
    String? referenceType,
  ) {
    final number = referenceNumber?.trim();
    if (number != null && number.isNotEmpty) {
      return number;
    }

    if (referenceId == null || referenceId.trim().isEmpty) {
      return inventoryEmDash;
    }

    if (_uuidPattern.hasMatch(referenceId.trim())) {
      return inventoryEmDash;
    }

    if (referenceType != null && _uuidPattern.hasMatch(referenceType.trim())) {
      return referenceId;
    }

    return referenceId;
  }

  static String _humanizeToken(String value) {
    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map(
          (part) => '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }
}
