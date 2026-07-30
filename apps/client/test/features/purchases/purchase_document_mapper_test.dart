import 'package:billing_baba/features/purchases/models/dto/purchase_document_dto.dart';
import 'package:billing_baba/features/purchases/models/mappers/purchase_document_mapper.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_model.dart';
import 'package:flutter_test/flutter_test.dart';

PurchaseDocumentDto _billDto({
  required String totalAmount,
  String paidAmount = '0',
  String status = 'finalized',
  String? dueDate,
  String documentDate = '2026-07-01',
}) {
  return PurchaseDocumentDto(
    id: 'bill-1',
    documentType: 'purchase_bill',
    status: status,
    documentSeries: 'PB',
    partyId: 'party-1',
    isGstFormal: false,
    subtotal: totalAmount,
    discountTotal: '0',
    taxAmount: '0',
    totalAmount: totalAmount,
    documentDate: documentDate,
    paidAmount: paidAmount,
    createdAt: '2026-07-01T00:00:00Z',
    updatedAt: '2026-07-01T00:00:00Z',
    dueDate: dueDate,
  );
}

void main() {
  group('PurchaseDocumentMapper bill status', () {
    test('maps fully paid bill', () {
      final model = PurchaseDocumentMapper.toBillModel(
        _billDto(totalAmount: '1000', paidAmount: '1000'),
      );
      expect(model.status, PurchaseBillStatus.paid);
    });

    test('maps partially paid bill within due date', () {
      final model = PurchaseDocumentMapper.toBillModel(
        _billDto(
          totalAmount: '1000',
          paidAmount: '400',
          dueDate: '2099-12-31',
        ),
      );
      expect(model.status, PurchaseBillStatus.partiallyPaid);
    });

    test('maps unpaid bill within due date', () {
      final model = PurchaseDocumentMapper.toBillModel(
        _billDto(
          totalAmount: '1000',
          dueDate: '2099-12-31',
        ),
      );
      expect(model.status, PurchaseBillStatus.unpaid);
    });

    test('maps overdue bill when past due with balance', () {
      final model = PurchaseDocumentMapper.toBillModel(
        _billDto(
          totalAmount: '1000',
          paidAmount: '200',
          dueDate: '2020-01-01',
        ),
      );
      expect(model.status, PurchaseBillStatus.overdue);
    });
  });
}
