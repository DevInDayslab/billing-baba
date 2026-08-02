import 'package:billing_baba/features/command_sync/application/command_sync_providers.dart';
import 'package:billing_baba/features/pos/models/payment_entry.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/pos/models/pos_sale_line_item.dart';
import 'package:billing_baba/features/pos/models/return_item.dart';
import 'package:billing_baba/features/pos/pos_constants.dart';
import 'package:billing_baba/features/pos/pos_exceptions.dart';
import 'package:billing_baba/features/sales/data/sales_invoice_command_repository.dart';
import 'package:billing_baba/features/sales/data/sales_return_command_repository.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/models/sales_document_draft_input.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'pos_return_service.g.dart';

const _uuid = Uuid();
const _posReturnTaxOption = '18%';

@Riverpod(keepAlive: true)
Future<PosReturnService> posReturnService(Ref ref) async {
  final commandRepository = await ref.watch(
    salesReturnCommandRepositoryProvider.future,
  );
  return PosReturnService(commandRepository: commandRepository);
}

class PosReturnService {
  PosReturnService({required SalesReturnCommandRepository commandRepository})
    : _commandRepository = commandRepository;

  final SalesReturnCommandRepository _commandRepository;

  Future<PosSale> processReturn({
    required PosSale originalSale,
    required List<ReturnItem> returnItems,
    required PaymentMode refundMode,
  }) async {
    if (returnItems.isEmpty) {
      throw const PosRepositoryException(
        message: 'No items selected for return',
      );
    }

    final totalRefundAmount = returnItems.fold<double>(
      0,
      (sum, item) => sum + item.lineTotal,
    );

    final draftInput = SalesDocumentDraftInput(
      documentType: SalesDocumentType.salesReturn,
      documentSeries: 'POS-RET',
      partyId: originalSale.partyId ?? PosConstants.walkInPartyId,
      convertedFromId: originalSale.id,
      documentDate: DateTime.now(),
      items: returnItems
          .map(
            (item) => SaleLineItem(
              id: _uuid.v4(),
              itemId: item.itemId,
              itemName: item.name,
              qty: item.quantity.toDouble(),
              unit: item.unit,
              pricePerUnit: double.tryParse(item.unitPrice) ?? 0,
              discountPercent: 0,
              mrp: double.tryParse(item.unitPrice) ?? 0,
            ),
          )
          .toList(),
      taxOption: _posReturnTaxOption,
      notes: 'Return for ${originalSale.docNumber}',
    );

    final itemNameToId = {
      for (final item in returnItems) item.name: item.itemId,
    };

    final draft = await _commandRepository.saveDraft(
      draftInput,
      itemNameToId: itemNameToId,
    );

    await _commandRepository.finalize(
      documentId: draft.id,
      localDocumentNumber: draft.documentNumber,
      payment: FinalizeSalePaymentCommand(
        amount: totalRefundAmount.toStringAsFixed(2),
        paymentMode: _paymentModeToApi(refundMode),
      ),
    );

    final finalizedDto =
        await _commandRepository.getDocument(draft.id) ?? draft;
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
  }

  String _paymentModeToApi(PaymentMode mode) => switch (mode) {
    PaymentMode.cash => 'cash',
    PaymentMode.upi => 'upi',
    PaymentMode.card => 'card',
    PaymentMode.bank => 'bank_transfer',
  };
}
