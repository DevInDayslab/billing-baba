import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/inventory/data/inventory_repository.dart';
import 'package:billing_baba/features/inventory/models/dto/item_dto.dart';
import 'package:billing_baba/features/parties/data/party_repository.dart';
import 'package:billing_baba/features/print/application/print_exception.dart';
import 'package:billing_baba/features/print/application/print_image_cache.dart';
import 'package:billing_baba/features/print/data/print_repository.dart';
import 'package:billing_baba/features/print/models/print_request.dart';
import 'package:billing_baba/features/print/models/printable_allocation.dart';
import 'package:billing_baba/features/print/models/printable_assets.dart';
import 'package:billing_baba/features/print/models/printable_company.dart';
import 'package:billing_baba/features/print/models/printable_document.dart';
import 'package:billing_baba/features/print/models/printable_document_kind.dart';
import 'package:billing_baba/features/print/models/printable_line_item.dart';
import 'package:billing_baba/features/print/models/printable_metadata.dart';
import 'package:billing_baba/features/print/models/printable_party.dart';
import 'package:billing_baba/features/print/models/printable_tax_summary.dart';
import 'package:billing_baba/features/print/models/printable_totals.dart';
import 'package:billing_baba/features/purchases/data/expense_repository.dart';
import 'package:billing_baba/features/purchases/data/purchase_fa_repository.dart';
import 'package:billing_baba/features/purchases/data/purchase_repository.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_dto.dart';
import 'package:billing_baba/features/sales/data/job_work_repository.dart';
import 'package:billing_baba/features/sales/data/sale_fa_repository.dart';
import 'package:billing_baba/features/sales/data/sales_repository.dart';
import 'package:billing_baba/features/sales/models/dto/job_work_order_dto.dart';
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
    required this._expenseRepository,
    required this._purchaseFaRepository,
    required this._saleFaRepository,
    required this._jobWorkRepository,
    required this._imageCache,
  });

  final SalesRepository _salesRepository;
  final PurchaseRepository _purchaseRepository;
  final InventoryRepository _inventoryRepository;
  final PrintRepository _printRepository;
  final BusinessService _businessService;
  final PartyRepository _partyRepository;
  final ExpenseRepository _expenseRepository;
  final PurchaseFaRepository _purchaseFaRepository;
  final SaleFaRepository _saleFaRepository;
  final JobWorkRepository _jobWorkRepository;
  final PrintImageCache _imageCache;
  final Map<String, ItemDetailDto> _itemCache = {};

  Future<PrintableDocument> load(PrintRequest request) {
    return switch (request) {
      SaleInvoicePrintRequest() ||
      EstimatePrintRequest() ||
      ProformaInvoicePrintRequest() ||
      DeliveryChallanPrintRequest() ||
      CreditNotePrintRequest() ||
      SaleOrderPrintRequest() => _loadSalesDocument(request),
      PurchaseBillPrintRequest() ||
      DebitNotePrintRequest() ||
      PurchaseOrderPrintRequest() => _loadPurchaseDocument(request),
      PaymentInPrintRequest() => _loadPayment(
        request,
        expectedDirection: 'received',
      ),
      PaymentOutPrintRequest() => _loadPayment(
        request,
        expectedDirection: 'paid',
      ),
      ExpensePrintRequest() => _loadExpense(request),
      FixedAssetPurchasePrintRequest() => _loadFixedAssetPurchase(request),
      SaleFaPrintRequest() => _loadSaleFa(request),
      JobWorkOrderPrintRequest() => _loadJobWorkOrder(request),
    };
  }

  Future<PrintableDocument> _loadSalesDocument(PrintRequest request) async {
    final documentFuture = _salesRepository.getDocument(request.id);
    final profileFuture = _businessService.fetchBusinessProfile();

    final document = await documentFuture;
    _assertSalesDocumentKind(document, request.kind);

    final profile = await profileFuture;
    final company = PrintableCompany(profile: profile);

    final partyFuture = _loadParty(document.partyId);
    final linesFuture = _enrichSalesLines(document.lines);
    final assetsFuture = _loadAssets(
      profile.logoUrl,
      profile.signatureUrl,
      profile.stampUrl,
    );

    late final PrintableParty? party;
    late final List<PrintableLineItem> lines;
    late final PrintableAssets assets;

    await Future.wait<void>([
      partyFuture.then((value) => party = value),
      linesFuture.then((value) => lines = value),
      assetsFuture.then((value) => assets = value),
    ]);

    return PrintableDocument(
      kind: request.kind,
      request: request,
      company: company,
      party: party,
      lines: lines,
      metadata: _metadataFromSales(document),
      totals: _totalsFromDocument(
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
    final documentFuture = _purchaseRepository.getDocument(request.id);
    final profileFuture = _businessService.fetchBusinessProfile();

    final document = await documentFuture;
    _assertPurchaseDocumentKind(document, request.kind);

    final profile = await profileFuture;
    final company = PrintableCompany(profile: profile);

    final partyFuture = _loadParty(document.partyId);
    final linesFuture = _enrichPurchaseLines(document.lines);
    final assetsFuture = _loadAssets(
      profile.logoUrl,
      profile.signatureUrl,
      profile.stampUrl,
    );

    late final PrintableParty? party;
    late final List<PrintableLineItem> lines;
    late final PrintableAssets assets;

    await Future.wait<void>([
      partyFuture.then((value) => party = value),
      linesFuture.then((value) => lines = value),
      assetsFuture.then((value) => assets = value),
    ]);

    return PrintableDocument(
      kind: request.kind,
      request: request,
      company: company,
      party: party,
      lines: lines,
      metadata: _metadataFromPurchase(document),
      totals: _totalsFromDocument(
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

    final profile = await _businessService.fetchBusinessProfile();
    final company = PrintableCompany(profile: profile);

    final partyFuture = _loadParty(payment.partyId);
    final assetsFuture = _loadAssets(
      profile.logoUrl,
      profile.signatureUrl,
      profile.stampUrl,
    );
    final allocationsFuture = _enrichAllocations(payment.allocations);

    late final PrintableParty? party;
    late final PrintableAssets assets;
    late final List<PrintableAllocation> allocations;

    await Future.wait<void>([
      partyFuture.then((value) => party = value),
      assetsFuture.then((value) => assets = value),
      allocationsFuture.then((value) => allocations = value),
    ]);

    return PrintableDocument(
      kind: request.kind,
      request: request,
      company: company,
      party: party,
      allocations: allocations,
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
      totals: _totalsFromDocument(
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

  Future<PrintableDocument> _loadExpense(PrintRequest request) async {
    final expense = await _expenseRepository.getExpense(request.id);
    final profile = await _businessService.fetchBusinessProfile();
    final company = PrintableCompany(profile: profile);

    final partyFuture = _loadParty(expense.partyId);
    final assetsFuture = _loadAssets(
      profile.logoUrl,
      profile.signatureUrl,
      profile.stampUrl,
    );

    late final PrintableParty? party;
    late final PrintableAssets assets;

    await Future.wait<void>([
      partyFuture.then((value) => party = value),
      assetsFuture.then((value) => assets = value),
    ]);

    return PrintableDocument(
      kind: request.kind,
      request: request,
      company: company,
      party: party,
      metadata: PrintableMetadata(
        documentNumber: expense.referenceNumber ?? expense.id,
        documentSeries: null,
        documentDate: expense.expenseDate,
        status: 'finalized',
        paymentMode: expense.paymentMode,
        paymentReference: expense.referenceNumber,
        notes: expense.notes,
        expenseCategoryName: expense.categoryName,
        expenseDescription: expense.description,
      ),
      totals: _totalsFromDocument(
        subtotal: expense.amount,
        discountTotal: '0',
        taxAmount: expense.taxAmount ?? '0',
        totalAmount: expense.amount,
      ),
      taxSummary: PrintableTaxSummary.zero,
      assets: assets,
      expense: expense,
    );
  }

  Future<PrintableDocument> _loadFixedAssetPurchase(
    PrintRequest request,
  ) async {
    final batch = await _purchaseFaRepository.getBatch(request.id);
    final profile = await _businessService.fetchBusinessProfile();
    final company = PrintableCompany(profile: profile);

    final partyFuture = _loadParty(batch.partyId);
    final assetsFuture = _loadAssets(
      profile.logoUrl,
      profile.signatureUrl,
      profile.stampUrl,
    );

    late final PrintableParty? party;
    late final PrintableAssets assets;

    await Future.wait<void>([
      partyFuture.then((value) => party = value),
      assetsFuture.then((value) => assets = value),
    ]);

    return PrintableDocument(
      kind: request.kind,
      request: request,
      company: company,
      party: party,
      metadata: PrintableMetadata(
        documentNumber: batch.referenceNumber ?? batch.id,
        documentSeries: null,
        documentDate: batch.purchaseDate,
        status: batch.status,
        paymentMode: batch.paymentMode,
        paymentReference: batch.referenceNumber,
        notes: batch.notes,
        dueDate: batch.dueDate,
      ),
      totals: _totalsFromDocument(
        subtotal: batch.subtotal,
        discountTotal: '0',
        taxAmount: batch.taxAmount,
        totalAmount: batch.totalAmount,
      ),
      taxSummary: PrintableTaxSummary.zero,
      assets: assets,
      purchaseFaBatch: batch,
    );
  }

  Future<PrintableDocument> _loadSaleFa(PrintRequest request) async {
    final batch = await _saleFaRepository.getBatch(request.id);
    final profile = await _businessService.fetchBusinessProfile();
    final company = PrintableCompany(profile: profile);

    final partyFuture = _loadParty(batch.partyId);
    final assetsFuture = _loadAssets(
      profile.logoUrl,
      profile.signatureUrl,
      profile.stampUrl,
    );

    late final PrintableParty? party;
    late final PrintableAssets assets;

    await Future.wait<void>([
      partyFuture.then((value) => party = value),
      assetsFuture.then((value) => assets = value),
    ]);

    return PrintableDocument(
      kind: request.kind,
      request: request,
      company: company,
      party: party,
      metadata: PrintableMetadata(
        documentNumber: batch.referenceNumber ?? batch.id,
        documentSeries: null,
        documentDate: batch.saleDate,
        status: batch.status,
        paymentMode: batch.paymentMode,
        paymentReference: batch.referenceNumber,
        notes: batch.notes,
        dueDate: batch.dueDate,
      ),
      totals: _totalsFromDocument(
        subtotal: batch.subtotal,
        discountTotal: '0',
        taxAmount: batch.taxAmount,
        totalAmount: batch.totalAmount,
      ),
      taxSummary: PrintableTaxSummary.zero,
      assets: assets,
      saleFaBatch: batch,
    );
  }

  Future<PrintableDocument> _loadJobWorkOrder(PrintRequest request) async {
    final order = await _jobWorkRepository.getOrder(request.id);
    final profile = await _businessService.fetchBusinessProfile();
    final company = PrintableCompany(profile: profile);

    final partyFuture = _loadParty(order.partyId);
    final assetsFuture = _loadAssets(
      profile.logoUrl,
      profile.signatureUrl,
      profile.stampUrl,
    );
    final materialNamesFuture = _loadJobWorkMaterialNames(order.rawMaterials);

    late final PrintableParty? party;
    late final PrintableAssets assets;
    late final Map<String, String> materialNames;

    await Future.wait<void>([
      partyFuture.then((value) => party = value),
      assetsFuture.then((value) => assets = value),
      materialNamesFuture.then((value) => materialNames = value),
    ]);

    return PrintableDocument(
      kind: request.kind,
      request: request,
      company: company,
      party: party,
      metadata: PrintableMetadata(
        documentNumber: order.jobNumber ?? order.id,
        documentSeries: null,
        documentDate: order.orderDate,
        status: order.status,
        notes: order.notes,
        dueDate: order.deliveryDate,
      ),
      totals: _totalsFromDocument(
        subtotal: order.rawMaterialsTotal,
        discountTotal: '0',
        taxAmount: '0',
        totalAmount: order.grandTotal,
      ),
      taxSummary: PrintableTaxSummary.zero,
      assets: assets,
      jobWorkOrder: order,
      jobWorkMaterialNames: materialNames,
    );
  }

  Future<List<PrintableAllocation>> _enrichAllocations(
    List<PaymentAllocationDto> allocations,
  ) async {
    if (allocations.isEmpty) return const [];

    final enriched = await Future.wait(
      allocations.map(_enrichAllocation),
    );
    return enriched.whereType<PrintableAllocation>().toList();
  }

  Future<PrintableAllocation?> _enrichAllocation(
    PaymentAllocationDto allocation,
  ) async {
    try {
      if (allocation.salesDocumentId != null) {
        final doc = await _salesRepository.getDocument(
          allocation.salesDocumentId!,
        );
        return PrintableAllocation(
          invoiceNumber: doc.documentNumber ?? doc.id,
          invoiceDate: doc.documentDate,
          allocatedAmount: allocation.allocatedAmount,
        );
      }
      if (allocation.purchaseDocumentId != null) {
        final doc = await _purchaseRepository.getDocument(
          allocation.purchaseDocumentId!,
        );
        return PrintableAllocation(
          invoiceNumber: doc.documentNumber ?? doc.id,
          invoiceDate: doc.documentDate,
          allocatedAmount: allocation.allocatedAmount,
        );
      }
    } on Object {
      return null;
    }
    return null;
  }

  Future<Map<String, String>> _loadJobWorkMaterialNames(
    List<JobWorkRawMaterialDto> materials,
  ) async {
    if (materials.isEmpty) return const {};

    final items = await _loadItemsById(materials.map((m) => m.itemId));
    return {
      for (final material in materials)
        material.itemId: items[material.itemId]?.name ?? material.itemId,
    };
  }

  Future<PrintableParty?> _loadParty(String? partyId) async {
    if (partyId == null || partyId.isEmpty) {
      return null;
    }
    final dto = await _partyRepository.getParty(partyId);
    return PrintableParty(dto: dto);
  }

  Future<PrintableAssets> _loadAssets(
    String? logoUrl,
    String? signatureUrl,
    String? stampUrl,
  ) async {
    final results = await Future.wait([
      _imageCache.getBytes(logoUrl),
      _imageCache.getBytes(signatureUrl),
      _imageCache.getBytes(stampUrl),
    ]);
    return PrintableAssets(
      logoBytes: results[0],
      signatureBytes: results[1],
      stampBytes: results[2],
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
        final cached = _itemCache[id];
        if (cached != null) return MapEntry(id, cached);
        final item = await _inventoryRepository.getItem(id);
        _itemCache[id] = item;
        return MapEntry(id, item);
      }),
    );
    return Map.fromEntries(entries);
  }

  PrintableTotals _totalsFromDocument({
    required String subtotal,
    required String discountTotal,
    required String taxAmount,
    required String totalAmount,
  }) {
    return PrintableTotals(
      subtotal: subtotal,
      discountTotal: discountTotal,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
    );
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
      case PrintableDocumentKind.saleOrder:
        if (document.documentType != SalesDocumentType.saleOrder.apiValue) {
          throw PrintException(
            'Document ${document.id} is not a sale order',
          );
        }
        return;
      case PrintableDocumentKind.purchaseBill:
      case PrintableDocumentKind.debitNote:
      case PrintableDocumentKind.purchaseOrder:
      case PrintableDocumentKind.paymentIn:
      case PrintableDocumentKind.paymentOut:
      case PrintableDocumentKind.expense:
      case PrintableDocumentKind.fixedAssetPurchase:
      case PrintableDocumentKind.saleFa:
      case PrintableDocumentKind.jobWorkOrder:
      case PrintableDocumentKind.posReceipt:
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
      case PrintableDocumentKind.purchaseOrder:
        if (document.documentType != 'purchase_order') {
          throw PrintException(
            'Document ${document.id} is not a purchase order',
          );
        }
        return;
      case PrintableDocumentKind.saleInvoice:
      case PrintableDocumentKind.estimate:
      case PrintableDocumentKind.proformaInvoice:
      case PrintableDocumentKind.deliveryChallan:
      case PrintableDocumentKind.creditNote:
      case PrintableDocumentKind.saleOrder:
      case PrintableDocumentKind.paymentIn:
      case PrintableDocumentKind.paymentOut:
      case PrintableDocumentKind.expense:
      case PrintableDocumentKind.fixedAssetPurchase:
      case PrintableDocumentKind.saleFa:
      case PrintableDocumentKind.jobWorkOrder:
      case PrintableDocumentKind.posReceipt:
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
