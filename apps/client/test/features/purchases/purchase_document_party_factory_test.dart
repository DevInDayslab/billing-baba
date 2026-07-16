import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/purchases/application/purchase_document_party_factory.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_parse_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PurchaseDocumentPartyFactory', () {
    test('needsCreation when vendor is unknown', () {
      const parsed = PurchaseDocumentParseDto(
        vendorName: 'Acme Supplies',
        gstin: '27AABCU9603R1ZM',
      );

      expect(
        PurchaseDocumentPartyFactory.needsCreation(parsed, const []),
        isTrue,
      );
    });

    test('does not need creation when party already exists', () {
      const parsed = PurchaseDocumentParseDto(
        vendorName: 'Acme Supplies',
        gstin: '27AABCU9603R1ZM',
      );
      const parties = [
        PartyModel(
          id: 'party-1',
          name: 'Acme Supplies',
          phone: '',
          gstin: '27AABCU9603R1ZM',
          partyType: 'supplier',
        ),
      ];

      expect(
        PurchaseDocumentPartyFactory.needsCreation(parsed, parties),
        isFalse,
      );
    });

    test('builds supplier party payload from parsed vendor fields', () {
      const parsed = PurchaseDocumentParseDto(
        vendorName: 'Acme Supplies',
        gstin: '27AABCU9603R1ZM',
        vendorPhone: '9876543210',
        vendorEmail: 'billing@acme.test',
        vendorAddress: '12 Market Road',
        vendorCity: 'Mumbai',
        vendorPincode: '400001',
        vendorState: 'Maharashtra',
      );

      final result = PurchaseDocumentPartyFactory.toAddPartyResult(parsed);

      expect(result.partyName, 'Acme Supplies');
      expect(result.partyType, 'supplier');
      expect(result.gstin, '27AABCU9603R1ZM');
      expect(result.phone, '9876543210');
      expect(result.email, 'billing@acme.test');
      expect(result.state, 'Maharashtra');
      expect(result.addressLine, '12 Market Road');
      expect(result.city, 'Mumbai');
      expect(result.pincode, '400001');
      expect(result.gstType, 'Registered Business - Regular');
    });

    test('drops invalid OCR contact fields instead of failing API validation', () {
      const parsed = PurchaseDocumentParseDto(
        vendorName: 'Acme Supplies',
        gstin: 'INVALID-GSTIN',
        vendorPhone: '12',
        vendorEmail: 'not-an-email',
      );

      final result = PurchaseDocumentPartyFactory.toAddPartyResult(parsed);

      expect(result.gstin, '');
      expect(result.phone, '');
      expect(result.email, '');
      expect(result.gstType, 'Unregistered/Consumer');
    });
  });
}
