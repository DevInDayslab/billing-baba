import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/pos/models/pos_sale_line_item.dart';
import 'package:billing_baba/features/pos/models/return_item.dart';
import 'package:billing_baba/features/pos/pos_constants.dart';
import 'package:billing_baba/features/pos/pos_exceptions.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/data/sales_remote_data_source.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pos_return_service.g.dart';

@Riverpod(keepAlive: true)
Future<PosReturnService> posReturnService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return PosReturnService(remote: SalesRemoteDataSource(api.dio));
}

class PosReturnService {
  PosReturnService({required SalesRemoteDataSource remote}) : _remote = remote;

  final SalesRemoteDataSource _remote;

  Future<PosSale> processReturn({
    required PosSale originalSale,
    required List<ReturnItem> returnItems,
    required PaymentMode refundMode,
  }) async {
    if (returnItems.isEmpty) {
      throw const PosRepositoryException(message: 'No items selected for return');
    }

    final totalRefundAmount = returnItems.fold<double>(
      0,
      (sum, item) => sum + item.lineTotal,
    );

    try {
      final returnDoc = await _remote.createDocument(
        CreateSalesDocumentRequest(
          documentType: 'sales_return',
          documentSeries: 'POS-RET',
          partyId: originalSale.partyId ?? PosConstants.walkInPartyId,
          convertedFromId: originalSale.id,
        ),
      );

      for (var i = 0; i < returnItems.length; i++) {
        final item = returnItems[i];
        await _remote.addLine(
          returnDoc.id,
          CreateSalesLineRequest(
            itemId: item.itemId,
            quantity: item.quantity.toString(),
            unit: item.unit,
            unitPrice: item.unitPrice,
            sortOrder: i,
          ),
        );
      }

      final finalizedDto = await _remote.finalizeDocument(returnDoc.id);

      await _remote.createPayment(
        CreatePaymentRequest(
          partyId: originalSale.partyId ?? PosConstants.walkInPartyId,
          direction: 'paid',
          amount: totalRefundAmount.toStringAsFixed(2),
          paymentMode: _paymentModeToApi(refundMode),
          allocations: [
            PaymentAllocationRequest(
              salesDocumentId: returnDoc.id,
              allocatedAmount: totalRefundAmount.toStringAsFixed(2),
            ),
          ],
        ),
      );

      final completedAt =
          DateTime.tryParse(finalizedDto.createdAt) ?? DateTime.now();

      return PosSale(
        id: finalizedDto.id,
        docNumber: finalizedDto.documentNumber ?? finalizedDto.id,
        partyId: originalSale.partyId,
        customerName: originalSale.customerName,
        items: returnItems
            .map(
              (item) => PosSaleLineItem(
                name: item.name,
                quantity: item.quantity,
                lineTotal: item.lineTotal,
                itemId: item.itemId,
                unit: item.unit,
                unitPrice: double.tryParse(item.unitPrice),
              ),
            )
            .toList(),
        payments: [
          PaymentEntry(mode: refundMode, amount: totalRefundAmount),
        ],
        paymentMethod: _paymentModeToApi(refundMode),
        totalAmount: totalRefundAmount,
        taxAmount: double.tryParse(finalizedDto.taxAmount) ?? 0,
        finalAmount: totalRefundAmount,
        completedAt: completedAt,
        itemCount: returnItems.fold<int>(0, (sum, item) => sum + item.quantity),
        notes: 'Return for ${originalSale.docNumber}',
      );
    } on DioException catch (error) {
      final salesError = mapSalesError(error);
      throw PosRepositoryException(message: salesError.message);
    }
  }

  String _paymentModeToApi(PaymentMode mode) => switch (mode) {
        PaymentMode.cash => 'cash',
        PaymentMode.upi => 'upi',
        PaymentMode.card => 'card',
        PaymentMode.bank => 'bank_transfer',
      };
}
