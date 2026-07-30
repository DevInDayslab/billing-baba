import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/inventory/data/inventory_stock_local_data_source.dart';
import 'package:billing_baba/features/purchases/data/purchase_local_data_source.dart';
import 'package:billing_baba/features/sales/data/sales_local_data_source.dart';

/// Applies command acks to local Drift documents.
class CommandAckApplier {
  CommandAckApplier({
    required AppDatabase db,
    SalesLocalDataSource? salesLocal,
    PurchaseLocalDataSource? purchaseLocal,
    InventoryStockLocalDataSource? stockLocal,
  }) : _salesLocal = salesLocal ?? SalesLocalDataSource(db),
       _purchaseLocal = purchaseLocal ?? PurchaseLocalDataSource(db),
       _stockLocal = stockLocal ?? InventoryStockLocalDataSource(db);

  final SalesLocalDataSource _salesLocal;
  final PurchaseLocalDataSource _purchaseLocal;
  final InventoryStockLocalDataSource _stockLocal;

  Future<void> apply({
    required String command,
    required Map<String, dynamic> result,
    required int syncVersion,
    required DateTime updatedAt,
  }) async {
    if (command == 'stock_adjustment') {
      await _applyStockAdjustmentAck(
        result: result,
        syncVersion: syncVersion,
        updatedAt: updatedAt,
      );
      return;
    }

    final documentId = result['document_id']?.toString();
    if (documentId == null) return;

    final status = result['status']?.toString() ?? 'finalized';
    final remap = result['document_number_remap'];
    String? documentNumber;
    if (remap is Map) {
      documentNumber = remap['server_document_number']?.toString();
    } else {
      documentNumber = result['document_number']?.toString();
    }

    switch (command) {
      case 'finalize_sale':
        await _salesLocal.applyFinalizeAck(
          documentId: documentId,
          status: status,
          documentNumber: documentNumber,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          paidAmount: result['paid_amount']?.toString(),
          paymentMode: result['payment_mode']?.toString(),
        );
      case 'finalize_credit_note':
        await _salesLocal.applyFinalizeAck(
          documentId: documentId,
          status: status,
          documentNumber: documentNumber,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          paidAmount: result['paid_amount']?.toString(),
          paymentMode: result['payment_mode']?.toString(),
        );
      case 'finalize_purchase':
        await _purchaseLocal.applyFinalizeAck(
          documentId: documentId,
          status: status,
          documentNumber: documentNumber,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          paidAmount: result['paid_amount']?.toString(),
          paymentMode: result['payment_mode']?.toString(),
        );
      case 'finalize_debit_note':
        await _purchaseLocal.applyFinalizeAck(
          documentId: documentId,
          status: status,
          documentNumber: documentNumber,
          syncVersion: syncVersion,
          updatedAt: updatedAt,
          paidAmount: result['paid_amount']?.toString(),
          paymentMode: result['payment_mode']?.toString(),
        );
      default:
        break;
    }
  }

  Future<void> _applyStockAdjustmentAck({
    required Map<String, dynamic> result,
    required int syncVersion,
    required DateTime updatedAt,
  }) async {
    final adjustmentId = result['adjustment_id']?.toString();
    if (adjustmentId == null || adjustmentId.isEmpty) return;

    final movementIds = result['movement_ids'];
    if (movementIds is! List) return;

    await _stockLocal.applyStockAdjustmentAck(
      adjustmentId: adjustmentId,
      movementIds: movementIds
          .whereType<Map>()
          .map(Map<String, dynamic>.from)
          .toList(),
      updatedAt: updatedAt,
      syncVersion: syncVersion,
    );
  }
}
