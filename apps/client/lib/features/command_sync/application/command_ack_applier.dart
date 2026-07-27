import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/purchases/data/purchase_local_data_source.dart';
import 'package:billing_baba/features/sales/data/sales_local_data_source.dart';

/// Applies finalize command acks to local Drift documents.
class CommandAckApplier {
  CommandAckApplier({
    required AppDatabase db,
    SalesLocalDataSource? salesLocal,
    PurchaseLocalDataSource? purchaseLocal,
  })  : _salesLocal = salesLocal ?? SalesLocalDataSource(db),
        _purchaseLocal = purchaseLocal ?? PurchaseLocalDataSource(db);

  final SalesLocalDataSource _salesLocal;
  final PurchaseLocalDataSource _purchaseLocal;

  Future<void> apply({
    required String command,
    required Map<String, dynamic> result,
    required int syncVersion,
    required DateTime updatedAt,
  }) async {
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
}
