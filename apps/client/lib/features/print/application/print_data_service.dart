import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/inventory/data/inventory_repository.dart';
import 'package:billing_baba/features/inventory/models/dto/item_dto.dart';
import 'package:billing_baba/features/parties/data/party_repository.dart';
import 'package:billing_baba/features/print/application/print_exception.dart';
import 'package:billing_baba/features/print/application/print_image_cache.dart';
import 'package:billing_baba/features/print/data/print_repository.dart';
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
import 'package:billing_baba/features/purchases/data/purchase_repository.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_dto.dart';
import 'package:billing_baba/features/sales/data/sales_repository.dart';
import 'package:billing_baba/features/sales/models/dto/sales_document_dto.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';

class PrintDataService {
  PrintDataService({
    required this._salesRepository,
    required this._purchaseRepository,
    required this._inventoryRepository,
    required this._printRepository,
    required this._businessService,
    required this._partyRepository,
    required this._imageCache,
  });

  final SalesRepository _salesRepository;
  final PurchaseRepository _purchaseRepository;
  final InventoryRepository _inventoryRepository;
  final PrintRepository _printRepository;
  final BusinessService _businessService;
  final PartyRepository _partyRepository;
  final PrintImageCache _imageCache;

  Future<PrintableDocument> load(PrintRequest request) {
    return switch (request) {
      SaleInvoicePrintRequest() ||
      EstimatePrintRequest() ||
      ProformaInvoicePrintRequest() ||
      DeliveryChallanPrintRequest() ||
      CreditNotePrintRequest() => _loadSalesDocument(request),
      PurchaseBillPrintRequest() || DebitNotePrintRequest() =>
        _loadPurchaseDocument(request),
      PaymentInPrintRequest() => _loadPayment(request, expectedDirection: 'received'),
      PaymentOutPrintRequest() => _loadPayment(request, expectedDirection: 'paid'),
    };
  }

  Future<PrintableDocument> _loadSalesDocument(PrintRequest request) async {
    final document = await _salesRepository.getDocument(request.id);
    _assertSalesDocumentKind(document, request.kind);

    final company = await _loadCompany();
    final party = await _loadParty(document.partyId);
    final lines = await _enrichSalesLines(document.lines);
    final assets = await _loadAssets(company.profile.logoUrl, company.profile.signatureUrl);

    return PrintableDocument(
      kind: request.kind,
      request: request,
      company: company,
      party: party,
      lines: lines,
      metadata: _metadataFromSales(document),
      totals: PrintableTotals(
        subtotal: document.subtotal,
        discountTotal: document.discountTotal,
        taxAmount: document.taxAmount,
        totalAmount: document.totalAmount,
      ),
      taxSummary: _taxSummaryFromSalesLines(document.lines),
      assets: assets,
      salesDocument: document,
    );
  }

  Future<PrintableDocument> _loadPurchaseDocument(PrintRequest request) async {
    final document = await _purchaseRepository.getDocument(request.id);
    _assertPurchaseDocumentKind(document, request.kind);

    final company = await _loadCompany();
    final party = await _loadParty(document.partyId);
    final lines = await _enrichPurchaseLines(document.lines);
    final assets = await _loadAssets(company.profile.logoUrl, company.profile.signatureUrl);

    return PrintableDocument(
      kind: request.kind,
      request: request,
      company: company,
      party: party,
      lines: lines,
      metadata: _metadataFromPurchase(document),
      totals: PrintableTotals(
        subtotal: document.subtotal,
        discountTotal: document.discountTotal,
        taxAmount: document.taxAmount,
        totalAmount: document.totalAmount,
      ),
      taxSummary: _taxSummaryFromPurchaseLines(document.lines),
      assets: assets,
      purchaseDocument: document,
    );
  }

  Future<PrintableDocument> _loadPayment(
    PrintRequest request, {
    required String expectedDirection,
  }) async {
    final payment = await _printRepository.getPayment(request.id);
    if (payment.direction != expectedDirection) {
      throw PrintException(
        'Payment direction mismatch: expected $expectedDirection, '
        'got ${payment.direction}',
      );
    }

    final company = await _loadCompany();
    final party = await _loadParty(payment.partyId);
    final assets = await _loadAssets(company.profile.logoUrl, company.profile.signatureUrl);

    return PrintableDocument(
      kind: request.kind,
      request: request,
      company: company,
      party: party,
      metadata: PrintableMetadata(
        documentNumber: payment.referenceNumber ?? payment.id,
        documentSeries: null,
        documentDate: payment.paymentDate,
        status: 'finalized',
        paymentMode: payment.paymentMode,
        paymentReference: payment.referenceNumber,
        paymentDirection: payment.direction,
        notes: payment.notes,
      ),
      totals: PrintableTotals(
        subtotal: payment.amount,
        discountTotal: '0',
        taxAmount: '0',
        totalAmount: payment.amount,
      ),
      taxSummary: PrintableTaxSummary.zero,
      assets: assets,
      payment: payment,
    );
  }

  Future<PrintableCompany> _loadCompany() async {
    final profile = await _businessService.fetchBusinessProfile();
    return PrintableCompany(profile: profile);
  }

  Future<PrintableParty?> _loadParty(String? partyId) async {
    if (partyId == null || partyId.isEmpty) {
      return null;
    }
    final dto = await _partyRepository.getParty(partyId);
    return PrintableParty(dto: dto);
  }

  Future<PrintableAssets> _loadAssets(String? logoUrl, String? signatureUrl) async {
    final results = await Future.wait([
      _imageCache.getBytes(logoUrl),
      _imageCache.getBytes(signatureUrl),
    ]);
    return PrintableAssets(
      logoBytes: results[0],
      signatureBytes: results[1],
    );
  }

  Future<List<PrintableLineItem>> _enrichSalesLines(
    List<SalesDocumentLineDto> lines,
  ) async {
    final items = await _loadItemsById(lines.map((line) => line.itemId));
    return [
      for (final line in lines)
        PrintableLineItem(line: line, item: items[line.itemId]),
    ];
  }

  Future<List<PrintableLineItem>> _enrichPurchaseLines(
    List<PurchaseDocumentLineDto> lines,
  ) async {
    final items = await _loadItemsById(lines.map((line) => line.itemId));
    return [
      for (final line in lines)
        PrintableLineItem(
          line: SalesDocumentLineDto(
            id: line.id,
            itemId: line.itemId,
            quantity: line.quantity,
            unit: line.unit,
            unitPrice: line.unitPrice,
            discountAmount: line.discountAmount,
            taxType: line.taxType,
            taxRate: line.taxRate,
            cgstAmount: line.cgstAmount,
            sgstAmount: line.sgstAmount,
            igstAmount: line.igstAmount,
            lineTotal: line.lineTotal,
            sortOrder: line.sortOrder,
          ),
          item: items[line.itemId],
        ),
    ];
  }

  Future<Map<String, ItemDetailDto>> _loadItemsById(
    Iterable<String> itemIds,
  ) async {
    final uniqueIds = itemIds.toSet();
    final entries = await Future.wait(
      uniqueIds.map((id) async {
        final item = await _inventoryRepository.getItem(id);
        return MapEntry(id, item);
      }),
    );
    return Map.fromEntries(entries);
  }

  void _assertSalesDocumentKind(
    SalesDocumentDto document,
    PrintableDocumentKind kind,
  ) {
    switch (kind) {
      case PrintableDocumentKind.saleInvoice:
        if (document.documentType != SalesDocumentType.taxInvoice.apiValue &&
            document.documentType != SalesDocumentType.normalInvoice.apiValue &&
            document.documentType != SalesDocumentType.billOfSupply.apiValue &&
            document.documentType != SalesDocumentType.pos.apiValue) {
          throw PrintException(
            'Document ${document.id} is not a sales invoice (type: '
            '${document.documentType})',
          );
        }
        return;
      case PrintableDocumentKind.estimate:
        if (document.documentType != SalesDocumentType.estimate.apiValue ||
            document.documentSeries == SalesConstants.proformaSeries) {
          throw PrintException(
            'Document ${document.id} is not an estimate',
          );
        }
        return;
      case PrintableDocumentKind.proformaInvoice:
        if (document.documentType != SalesDocumentType.estimate.apiValue ||
            document.documentSeries != SalesConstants.proformaSeries) {
          throw PrintException(
            'Document ${document.id} is not a proforma invoice',
          );
        }
        return;
      case PrintableDocumentKind.deliveryChallan:
        if (document.documentType !=
            SalesDocumentType.deliveryChallan.apiValue) {
          throw PrintException(
            'Document ${document.id} is not a delivery challan',
          );
        }
        return;
      case PrintableDocumentKind.creditNote:
        if (document.documentType != SalesDocumentType.salesReturn.apiValue) {
          throw PrintException(
            'Document ${document.id} is not a credit note',
          );
        }
        return;
      case PrintableDocumentKind.purchaseBill:
      case PrintableDocumentKind.debitNote:
      case PrintableDocumentKind.paymentIn:
      case PrintableDocumentKind.paymentOut:
        throw PrintException('Unexpected sales document kind: $kind');
    }
  }

  void _assertPurchaseDocumentKind(
    PurchaseDocumentDto document,
    PrintableDocumentKind kind,
  ) {
    switch (kind) {
      case PrintableDocumentKind.purchaseBill:
        if (document.documentType != 'purchase_bill') {
          throw PrintException(
            'Document ${document.id} is not a purchase bill',
          );
        }
        return;
      case PrintableDocumentKind.debitNote:
        if (document.documentType != 'purchase_return') {
          throw PrintException(
            'Document ${document.id} is not a debit note',
          );
        }
        return;
      case PrintableDocumentKind.saleInvoice:
      case PrintableDocumentKind.estimate:
      case PrintableDocumentKind.proformaInvoice:
      case PrintableDocumentKind.deliveryChallan:
      case PrintableDocumentKind.creditNote:
      case PrintableDocumentKind.paymentIn:
      case PrintableDocumentKind.paymentOut:
        throw PrintException('Unexpected purchase document kind: $kind');
    }
  }

  PrintableMetadata _metadataFromSales(SalesDocumentDto document) {
    return PrintableMetadata(
      documentNumber: document.documentNumber,
      documentSeries: document.documentSeries,
      documentDate: document.documentDate,
      status: document.status,
      apiDocumentType: document.documentType,
      notes: document.notes,
      isGstFormal: document.isGstFormal,
    );
  }

  PrintableMetadata _metadataFromPurchase(PurchaseDocumentDto document) {
    return PrintableMetadata(
      documentNumber: document.documentNumber,
      documentSeries: document.documentSeries,
      documentDate: document.documentDate,
      status: document.status,
      apiDocumentType: document.documentType,
      notes: document.notes,
      dueDate: document.dueDate,
      supplierInvoiceNumber: document.supplierInvoiceNumber,
      isGstFormal: document.isGstFormal,
    );
  }

  PrintableTaxSummary _taxSummaryFromSalesLines(
    List<SalesDocumentLineDto> lines,
  ) {
    return _taxSummaryFromAmounts(
      cgst: lines.fold<double>(
        0,
        (sum, line) => sum + (double.tryParse(line.cgstAmount) ?? 0),
      ),
      sgst: lines.fold<double>(
        0,
        (sum, line) => sum + (double.tryParse(line.sgstAmount) ?? 0),
      ),
      igst: lines.fold<double>(
        0,
        (sum, line) => sum + (double.tryParse(line.igstAmount) ?? 0),
      ),
    );
  }

  PrintableTaxSummary _taxSummaryFromPurchaseLines(
    List<PurchaseDocumentLineDto> lines,
  ) {
    return _taxSummaryFromAmounts(
      cgst: lines.fold<double>(
        0,
        (sum, line) => sum + (double.tryParse(line.cgstAmount) ?? 0),
      ),
      sgst: lines.fold<double>(
        0,
        (sum, line) => sum + (double.tryParse(line.sgstAmount) ?? 0),
      ),
      igst: lines.fold<double>(
        0,
        (sum, line) => sum + (double.tryParse(line.igstAmount) ?? 0),
      ),
    );
  }

  PrintableTaxSummary _taxSummaryFromAmounts({
    required double cgst,
    required double sgst,
    required double igst,
  }) {
    final taxTotal = cgst + sgst + igst;
    return PrintableTaxSummary(
      cgstTotal: _formatAmount(cgst),
      sgstTotal: _formatAmount(sgst),
      igstTotal: _formatAmount(igst),
      taxTotal: _formatAmount(taxTotal),
    );
  }

  String _formatAmount(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(2);
  }
}
