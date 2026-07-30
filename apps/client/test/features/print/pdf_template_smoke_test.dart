import 'package:billing_baba/features/business/models/business_profile_model.dart';
import 'package:billing_baba/features/parties/models/party_dto.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/models/printable_assets.dart';
import 'package:billing_baba/features/print/models/printable_company.dart';
import 'package:billing_baba/features/print/models/printable_document.dart';
import 'package:billing_baba/features/print/models/printable_document_kind.dart';
import 'package:billing_baba/features/print/models/printable_line_item.dart';
import 'package:billing_baba/features/print/models/printable_metadata.dart';
import 'package:billing_baba/features/print/models/printable_party.dart';
import 'package:billing_baba/features/print/models/printable_tax_summary.dart';
import 'package:billing_baba/features/print/models/printable_totals.dart';
import 'package:billing_baba/features/print/templates/a4_commercial_document_template.dart';
import 'package:billing_baba/features/print/templates/a4_voucher_template.dart';
import 'package:billing_baba/features/sales/models/dto/sales_document_dto.dart';
import 'package:billing_baba/features/settings/models/print_settings.dart';
import 'package:billing_baba/features/settings/services/invoice_print_document_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';

PrintableDocument _commercialFixture() {
  const line = SalesDocumentLineDto(
    id: 'line-1',
    itemId: 'item-1',
    quantity: '1',
    unit: 'pcs',
    unitPrice: '100',
    discountAmount: '0',
    taxType: 'gst',
    taxRate: '18',
    cgstAmount: '9',
    sgstAmount: '9',
    igstAmount: '0',
    lineTotal: '118',
    sortOrder: 0,
  );

  return const PrintableDocument(
    kind: PrintableDocumentKind.saleInvoice,
    request: PrintRequest.saleInvoice('inv-1'),
    company: PrintableCompany(
      profile: BusinessProfileModel(
        id: 'biz-1',
        name: 'Test Business',
      ),
    ),
    party: PrintableParty(
      dto: PartyDto(
        id: 'party-1',
        name: 'Test Party',
        partyType: 'customer',
        pricingTier: 'tier_1',
        creditLimit: '0',
        openingBalance: '0',
        balance: '0',
        isActive: true,
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      ),
    ),
    lines: [PrintableLineItem(line: line)],
    metadata: PrintableMetadata(
      documentNumber: 'INV-001',
      documentSeries: 'INV',
      documentDate: '2026-07-05',
      status: 'finalized',
    ),
    totals: PrintableTotals(
      subtotal: '100',
      discountTotal: '0',
      taxAmount: '18',
      totalAmount: '118',
    ),
    taxSummary: PrintableTaxSummary.zero,
    assets: PrintableAssets(),
  );
}

PrintableDocument _voucherFixture() {
  return const PrintableDocument(
    kind: PrintableDocumentKind.paymentIn,
    request: PrintRequest.paymentIn('pay-1'),
    company: PrintableCompany(
      profile: BusinessProfileModel(
        id: 'biz-1',
        name: 'Test Business',
      ),
    ),
    party: PrintableParty(
      dto: PartyDto(
        id: 'party-1',
        name: 'Test Party',
        partyType: 'customer',
        pricingTier: 'tier_1',
        creditLimit: '0',
        openingBalance: '0',
        balance: '0',
        isActive: true,
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      ),
    ),
    metadata: PrintableMetadata(
      documentNumber: 'RCPT-001',
      documentSeries: 'RCPT',
      documentDate: '2026-07-05',
      status: 'finalized',
      paymentMode: 'Cash',
    ),
    totals: PrintableTotals(
      subtotal: '0',
      discountTotal: '0',
      taxAmount: '0',
      totalAmount: '1000',
    ),
    taxSummary: PrintableTaxSummary.zero,
    assets: PrintableAssets(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (
            methodCall,
          ) async {
            return '.';
          },
        );
  });

  group('PDF template smoke tests', () {
    test('A4CommercialDocumentTemplate renders non-empty PDF bytes', () async {
      final bytes = await A4CommercialDocumentTemplate().render(
        _commercialFixture(),
      );

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });

    test('A4CommercialDocumentTemplate paginates 100+ line items', () async {
      final lines = List<PrintableLineItem>.generate(120, (index) {
        return PrintableLineItem(
          line: SalesDocumentLineDto(
            id: 'line-$index',
            itemId: 'item-$index',
            quantity: '${index + 1}',
            unit: 'pcs',
            unitPrice: '100',
            discountAmount: '0',
            taxType: 'gst',
            taxRate: '18',
            cgstAmount: '9',
            sgstAmount: '9',
            igstAmount: '0',
            lineTotal: '118',
            sortOrder: index,
          ),
        );
      });

      final document = PrintableDocument(
        kind: PrintableDocumentKind.saleInvoice,
        request: const PrintRequest.saleInvoice('inv-large'),
        company: _commercialFixture().company,
        party: _commercialFixture().party,
        lines: lines,
        metadata: const PrintableMetadata(
          documentNumber: 'INV-LARGE',
          documentSeries: 'INV',
          documentDate: '2026-07-05',
          status: 'draft',
          isGstFormal: true,
        ),
        totals: const PrintableTotals(
          subtotal: '12000',
          discountTotal: '0',
          taxAmount: '2160',
          totalAmount: '14160',
        ),
        taxSummary: PrintableTaxSummary.zero,
        assets: const PrintableAssets(),
      );

      final bytes = await A4CommercialDocumentTemplate().render(document);

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });

    test('A4VoucherTemplate renders non-empty PDF bytes', () async {
      final bytes = await A4VoucherTemplate().render(_voucherFixture());

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });

    test(
      'InvoicePrintDocumentService renders sales invoice with print settings',
      () async {
        const settings = PrintSettings.defaults();
        final bytes =
            await InvoicePrintDocumentService.buildBytesFromPrintableDocument(
              settings: settings,
              document: _commercialFixture(),
            );

        expect(bytes, isNotEmpty);
        expect(String.fromCharCodes(bytes.take(4)), '%PDF');
      },
    );

    test('thermal print settings produce a narrow PDF page width', () async {
      const settings = PrintSettings.defaults();
      final bytes =
          await InvoicePrintDocumentService.buildBytesFromPrintableDocument(
            settings: settings,
            document: _commercialFixture(),
          );

      final pdfText = String.fromCharCodes(bytes);
      final mediaBoxMatch = RegExp(
        r'/MediaBox\s*\[\s*0\s+0\s+([\d.]+)',
      ).firstMatch(pdfText);
      expect(mediaBoxMatch, isNotNull);

      final pageWidth = double.parse(mediaBoxMatch!.group(1)!);
      expect(
        pageWidth,
        lessThan(PdfPageFormat.a4.width * 0.6),
        reason: 'Thermal PDF width should be much narrower than A4',
      );
    });
  });
}
