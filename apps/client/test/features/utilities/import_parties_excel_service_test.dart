import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/utilities/application/import_parties_excel_parser.dart';
import 'package:billing_baba/features/utilities/application/import_parties_excel_service.dart';
import 'package:billing_baba/features/utilities/models/import_item_preview_row.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImportPartiesExcelService.buildPreviewRows', () {
    const parsedRows = [
      ParsedImportPartyExcelRow(
        sheetRowNumber: 2,
        partyName: 'Acme Retailers',
        mobile: '9876543210',
        partyType: 'customer',
        email: 'acme@example.com',
        gstin: '',
        state: 'Maharashtra',
        partyGroup: 'Retail',
        openingBalance: '1000',
      ),
    ];

    test('marks row valid with AddPartyResult', () {
      final rows = ImportPartiesExcelService.buildPreviewRows(
        parsedRows: parsedRows,
        existingParties: const [],
      );

      expect(rows, hasLength(1));
      expect(rows.first.status, ImportRowStatus.valid);
      expect(rows.first.isSelected, isTrue);
      expect(rows.first.importResult, isNotNull);
      expect(rows.first.importResult!.partyName, 'Acme Retailers');
      expect(rows.first.importResult!.phone, '9876543210');
    });

    test('marks missing name as error', () {
      final rows = ImportPartiesExcelService.buildPreviewRows(
        parsedRows: const [
          ParsedImportPartyExcelRow(
            sheetRowNumber: 2,
            partyName: '   ',
            mobile: '9876543210',
            partyType: 'customer',
            email: '',
            gstin: '',
            state: '',
            partyGroup: '',
            openingBalance: '0',
          ),
        ],
        existingParties: const [],
      );

      expect(rows.first.status, ImportRowStatus.error);
      expect(rows.first.issueMessage, contains('Party name'));
    });

    test('marks invalid mobile as error', () {
      final rows = ImportPartiesExcelService.buildPreviewRows(
        parsedRows: const [
          ParsedImportPartyExcelRow(
            sheetRowNumber: 2,
            partyName: 'Test Party',
            mobile: '123',
            partyType: 'customer',
            email: '',
            gstin: '',
            state: '',
            partyGroup: '',
            openingBalance: '0',
          ),
        ],
        existingParties: const [],
      );

      expect(rows.first.status, ImportRowStatus.error);
      expect(rows.first.issueMessage, isNotNull);
    });

    test('marks duplicate name in file', () {
      final rows = ImportPartiesExcelService.buildPreviewRows(
        parsedRows: const [
          ParsedImportPartyExcelRow(
            sheetRowNumber: 2,
            partyName: 'Same Name',
            mobile: '9876543210',
            partyType: 'customer',
            email: '',
            gstin: '',
            state: '',
            partyGroup: '',
            openingBalance: '0',
          ),
          ParsedImportPartyExcelRow(
            sheetRowNumber: 3,
            partyName: 'same name',
            mobile: '9123456789',
            partyType: 'customer',
            email: '',
            gstin: '',
            state: '',
            partyGroup: '',
            openingBalance: '0',
          ),
        ],
        existingParties: const [],
      );

      expect(rows[0].status, ImportRowStatus.valid);
      expect(rows[1].status, ImportRowStatus.duplicate);
    });

    test('marks existing party name as duplicate', () {
      const existing = [
        PartyModel(
          id: 'p1',
          name: 'Existing Co',
          phone: '9000000001',
        ),
      ];

      final rows = ImportPartiesExcelService.buildPreviewRows(
        parsedRows: const [
          ParsedImportPartyExcelRow(
            sheetRowNumber: 2,
            partyName: 'existing co',
            mobile: '9876543210',
            partyType: 'customer',
            email: '',
            gstin: '',
            state: '',
            partyGroup: '',
            openingBalance: '0',
          ),
        ],
        existingParties: existing,
      );

      expect(rows.first.status, ImportRowStatus.duplicate);
    });

    test('marks duplicate mobile against existing party', () {
      const existing = [
        PartyModel(
          id: 'p1',
          name: 'Other',
          phone: '9876543210',
        ),
      ];

      final rows = ImportPartiesExcelService.buildPreviewRows(
        parsedRows: parsedRows,
        existingParties: existing,
      );

      expect(rows.first.status, ImportRowStatus.duplicate);
      expect(rows.first.issueMessage, contains('mobile'));
    });
  });
}
