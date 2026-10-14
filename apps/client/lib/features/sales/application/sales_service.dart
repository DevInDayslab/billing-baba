import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/core/sync/providers/sync_providers.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/command_sync/application/command_sync_providers.dart';
import 'package:billing_baba/features/loyalty/models/loyalty_dto.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/data/sales_invoice_command_repository.dart';
import 'package:billing_baba/features/sales/data/sales_local_data_source.dart';
import 'package:billing_baba/features/sales/data/sales_remote_data_source.dart';
import 'package:billing_baba/features/sales/data/sales_repository.dart';
import 'package:billing_baba/features/sales/data/sales_return_command_repository.dart';
import 'package:billing_baba/features/sales/data/sales_sync_status.dart';
import 'package:billing_baba/features/sales/models/dto/sales_document_dto.dart';
import 'package:billing_baba/features/sales/models/mappers/sales_document_mapper.dart';
import 'package:billing_baba/features/sales/models/payment_in_model.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:billing_baba/features/sales/models/sale_document_model.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/models/sales_document_draft_input.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:billing_baba/features/sales/utils/sale_bill_tax.dart';
import 'package:billing_baba/shared/documents/document_line_id.dart';
import 'package:billing_baba/shared/documents/document_line_sync.dart';
import 'package:billing_baba/shared/utils/date_time_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'sales_error_mapper.dart' show SalesException, SalesOfflineException;

part 'sales_service.g.dart';

class CreateAndFinalizeSaleResult {
  const CreateAndFinalizeSaleResult({
    required this.document,
    this.loyalty,
    this.earnedLoyaltyPoints = 0,
  });

  final SalesDocumentDto document;
  final SaleLoyaltyResultDto? loyalty;
  final int earnedLoyaltyPoints;
}

@Riverpod(keepAlive: true)
Future<SalesService> salesService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  final partyService = await ref.watch(partyServiceProvider.future);
  final commandRepo = await ref.watch(
    salesInvoiceCommandRepositoryProvider.future,
  );
  final returnCommandRepo = await ref.watch(
    salesReturnCommandRepositoryProvider.future,
  );
  return SalesService(
    repository: SalesRepository(
      remote: SalesRemoteDataSource(api.dio),
      local: SalesLocalDataSource(ref.watch(appDatabaseProvider)),
    ),
    partyService: partyService,
    commandRepository: commandRepo,
    returnCommandRepository: returnCommandRepo,
    syncQueue: ref.watch(syncQueueProvider),
  );
}

class SalesService {
  SalesService({
    required this._repository,
    required this._partyService,
    this._commandRepository,
    this._returnCommandRepository,
    this._syncQueue,
  });

  final SalesRepository _repository;
  final PartyService _partyService;
  final SalesInvoiceCommandRepository? _commandRepository;
  final SalesReturnCommandRepository? _returnCommandRepository;
  final SyncQueue? _syncQueue;

  SalesRepository get repository => _repository;

  Future<Map<String, String>> _partyNameMap() async {
    final parties = await _partyService.fetchParties();
    return {for (final party in parties) party.id: party.name};
  }

  /// Shared party lookup for batched invoice page fetches.
  Future<Map<String, String>> fetchPartyNameMap() => _partyNameMap();

  Future<PaginatedSaleInvoices> fetchInvoicesPage(
    SalesDocumentListQuery query, {
    Map<String, String>? partyNames,
  }) async {
    final isTaxInvoiceQuery =
        query.documentType == SalesDocumentType.taxInvoice.apiValue;
    final isSalesReturnQuery =
        query.documentType == SalesDocumentType.salesReturn.apiValue;

    var localDocs = const <SalesDocumentDto>[];
    if (isTaxInvoiceQuery && _commandRepository != null) {
      try {
        localDocs = await _commandRepository.listTaxInvoices();
      } on Object {
        localDocs = const [];
      }
    } else if (isSalesReturnQuery && _returnCommandRepository != null) {
      try {
        localDocs = await _returnCommandRepository.listSalesReturns();
      } on Object {
        localDocs = const [];
      }
    }

    try {
      final resolvedPartyNames = partyNames ?? await _partyNameMap();
      final response = await _repository.listDocuments(query);
      final remoteDocs = response.documents;

      final mergedDocs =
          (isTaxInvoiceQuery || isSalesReturnQuery) && localDocs.isNotEmpty
          ? _mergeLocalSalesDocuments(remoteDocs, localDocs)
          : remoteDocs;

      final items =
          mergedDocs
              .map(
                (dto) => SalesDocumentMapper.toInvoiceModel(
                  dto,
                  partyName: dto.partyId != null
                      ? (resolvedPartyNames[dto.partyId] ?? '')
                      : '',
                ),
              )
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

      final total =
          (isTaxInvoiceQuery || isSalesReturnQuery) && localDocs.isNotEmpty
          ? items.length
          : response.meta.total;
      final totalPages = total == 0 ? 1 : (total / query.limit).ceil();
      final start = (query.page - 1) * query.limit;
      final pageItems = await _enrichInvoiceSyncState(
        items.skip(start).take(query.limit).toList(),
      );

      final summaryDto = response.summary;
      final summary = summaryDto == null
          ? null
          : SaleInvoiceSummaryData(
              totalSalesAmount: double.tryParse(summaryDto.totalAmount) ?? 0,
              receivedAmount: double.tryParse(summaryDto.receivedAmount) ?? 0,
              balanceAmount: double.tryParse(summaryDto.balanceAmount) ?? 0,
            );

      return PaginatedSaleInvoices(
        items: pageItems,
        currentPage: query.page,
        totalPages: totalPages,
        totalItems: total,
        summary: summary,
      );
    } on DioException catch (error) {
      if ((isTaxInvoiceQuery || isSalesReturnQuery) && localDocs.isNotEmpty) {
        final resolvedPartyNames = partyNames ?? await _partyNameMap();
        final sortedDocs = [...localDocs]
          ..sort((a, b) {
            final aDate = DateTimeUtils.parseApiDateTime(a.documentDate);
            final bDate = DateTimeUtils.parseApiDateTime(b.documentDate);
            return bDate.compareTo(aDate);
          });
        final items = sortedDocs
            .map(
              (dto) => SalesDocumentMapper.toInvoiceModel(
                dto,
                partyName: dto.partyId != null
                    ? (resolvedPartyNames[dto.partyId] ?? '')
                    : '',
              ),
            )
            .toList();

        final total = items.length;
        final totalPages = total == 0 ? 1 : (total / query.limit).ceil();
        final start = (query.page - 1) * query.limit;
        final pageItems = await _enrichInvoiceSyncState(
          items.skip(start).take(query.limit).toList(),
        );

        return PaginatedSaleInvoices(
          items: pageItems,
          currentPage: query.page,
          totalPages: totalPages,
          totalItems: total,
        );
      }
      throw mapSalesError(error);
    }
  }

  List<SalesDocumentDto> _mergeLocalSalesDocuments(
    List<SalesDocumentDto> remote,
    List<SalesDocumentDto> local,
  ) {
    final merged = <String, SalesDocumentDto>{
      for (final doc in remote) doc.id: doc,
    };

    for (final localDoc in local) {
      final remoteDoc = merged[localDoc.id];
      if (remoteDoc == null ||
          localDoc.status == 'draft' ||
          (localDoc.documentNumber?.startsWith('LOCAL-') ?? false) ||
          _shouldPreferLocalDocument(localDoc, remoteDoc)) {
        merged[localDoc.id] = localDoc;
      }
    }

    return merged.values.toList();
  }

  bool _shouldPreferLocalDocument(
    SalesDocumentDto local,
    SalesDocumentDto remote,
  ) {
    if (local.status == 'finalized' && remote.status == 'draft') {
      return true;
    }

    final localUpdated = DateTime.tryParse(local.updatedAt);
    final remoteUpdated = DateTime.tryParse(remote.updatedAt);
    if (localUpdated != null && remoteUpdated != null) {
      return localUpdated.isAfter(remoteUpdated);
    }
    return false;
  }

  Future<List<SaleInvoiceModel>> _enrichInvoiceSyncState(
    List<SaleInvoiceModel> invoices,
  ) async {
    if (_syncQueue == null || invoices.isEmpty) {
      return invoices;
    }

    final enriched = <SaleInvoiceModel>[];
    for (final invoice in invoices) {
      final jobs = await _syncQueue.listJobsForEntity(invoice.id);
      enriched.add(
        invoice.copyWith(
          syncState: resolveSaleInvoiceSyncState(
            jobs: jobs,
            isDraft: invoice.isDraft,
            invoiceNo: invoice.invoiceNo,
          ),
        ),
      );
    }
    return enriched;
  }

  Future<List<SaleInvoiceModel>> fetchInvoices({
    SalesDocumentListQuery? query,
  }) async {
    final page = await fetchInvoicesPage(
      query ??
          const SalesDocumentListQuery(
            documentType: 'tax_invoice',
            limit: 100,
          ),
    );
    return page.items;
  }

  Future<List<SaleInvoiceModel>> fetchDocumentsByType(
    SalesDocumentType type, {
    int limit = 100,
  }) async {
    final page = await fetchInvoicesPage(
      SalesDocumentListQuery(documentType: type.apiValue, limit: limit),
    );
    return page.items;
  }

  Future<PaginatedPaymentIn> fetchPaymentsPage(
    PaymentListQuery query, {
    Map<String, String>? partyNames,
  }) async {
    try {
      final resolvedPartyNames = partyNames ?? await _partyNameMap();
      final response = await _repository.listPayments(query);
      final items = response.payments
          .map(
            (dto) => SalesDocumentMapper.toPaymentInModel(
              dto,
              partyName: resolvedPartyNames[dto.partyId] ?? '',
            ),
          )
          .toList();

      final total = response.meta.total;
      final totalPages = total == 0 ? 1 : (total / query.limit).ceil();

      return PaginatedPaymentIn(
        items: items,
        currentPage: query.page,
        totalPages: totalPages,
        totalItems: total,
      );
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
  }

  Future<List<PaymentInModel>> fetchPayments({
    PaymentListQuery? query,
  }) async {
    final page = await fetchPaymentsPage(
      query ?? const PaymentListQuery(direction: 'received', limit: 100),
    );
    return page.items;
  }

  Future<AddSaleFormState> loadSaleForm(String documentId) async {
    SalesDocumentDto? document;
    if (_commandRepository != null) {
      document = await _commandRepository.getDocument(documentId);
    }

    if (document == null) {
      try {
        document = await _repository.getDocument(documentId);
      } on DioException catch (error) {
        throw mapSalesError(error);
      }
    }

    final partyNames = await _partyNameMap();
    final partyName = document.partyId != null
        ? (partyNames[document.partyId] ?? '')
        : '';

    final date = DateTimeUtils.parseApiDateTime(document.documentDate);
    final items = _linesToSaleLineItems(document.lines);

    return AddSaleFormState(
      documentId: document.id,
      partyId: document.partyId,
      billingName: partyName,
      invoiceNumber: document.documentNumber ?? 'Draft',
      invoiceNumberMode: document.documentNumber == null
          ? InvoiceNumberMode.auto
          : InvoiceNumberMode.manual,
      invoiceDate: DateTime(date.year, date.month, date.day),
      invoiceTime: TimeOfDay.fromDateTime(date),
      description: document.notes ?? '',
      items: items,
    );
  }

  Future<SalesDocumentDto> saveDocumentDraft(
    SalesDocumentDraftInput input, {
    required Map<String, String> itemNameToId,
  }) async {
    if (input.documentType == SalesDocumentType.taxInvoice &&
        _commandRepository != null) {
      return _commandRepository.saveDraft(input, itemNameToId: itemNameToId);
    }

    if (input.documentType == SalesDocumentType.salesReturn &&
        _returnCommandRepository != null) {
      return _returnCommandRepository.saveDraft(
        input,
        itemNameToId: itemNameToId,
      );
    }

    try {
      final document = input.documentId == null
          ? await _repository.createDocument(
              CreateSalesDocumentRequest(
                documentType: input.documentType.apiValue,
                documentSeries: input.documentSeries,
                partyId: input.partyId,
                isGstFormal: input.isGstFormal,
                documentDate: _apiDocumentDate(input),
                convertedFromId: input.convertedFromId,
                notes: input.notes?.trim().isEmpty ?? true ? null : input.notes,
              ),
            )
          : await _syncGenericDocumentHeader(input);

      await _syncLinesGeneric(
        documentId: document.id,
        items: input.items,
        itemNameToId: itemNameToId,
        existingLines: document.lines,
        taxOption: input.taxOption,
      );

      return _repository.getDocument(document.id);
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
  }

  Future<SalesDocumentDto> saveDraft(
    AddSaleFormState form, {
    required Map<String, String> itemNameToId,
    bool isGstFormal = true,
  }) {
    return saveDocumentDraft(
      SalesDocumentDraftInput(
        documentId: form.documentId,
        partyId: form.partyId,
        documentType: SalesDocumentType.taxInvoice,
        documentSeries: SalesConstants.defaultDocumentSeries,
        documentDate: form.invoiceDate,
        documentTime: form.invoiceTime,
        notes: form.description,
        godownId: form.godownId,
        isGstFormal: isGstFormal,
        convertedFromId: form.attachedSaleOrderIds.isNotEmpty
            ? form.attachedSaleOrderIds.first
            : null,
        items: form.items,
        taxOption: form.taxOption,
      ),
      itemNameToId: itemNameToId,
    );
  }

  Future<SalesDocumentDto> finalizeDocumentDraft(
    SalesDocumentDraftInput input, {
    required Map<String, String> itemNameToId,
    String? godownId,
    FinalizeSalePaymentCommand? payment,
  }) async {
    if (input.partyId == null || input.partyId!.isEmpty) {
      throw const SalesException('Party is required');
    }

    if (input.documentType == SalesDocumentType.taxInvoice &&
        _commandRepository != null) {
      final draft = await _commandRepository.saveDraft(
        input,
        itemNameToId: itemNameToId,
      );
      await _commandRepository.finalize(
        documentId: draft.id,
        localDocumentNumber: draft.documentNumber,
        godownId: godownId ?? input.godownId,
        payment: payment,
      );
      return draft;
    }

    if (input.documentType == SalesDocumentType.salesReturn &&
        _returnCommandRepository != null) {
      final draft = await _returnCommandRepository.saveDraft(
        input,
        itemNameToId: itemNameToId,
      );
      await _returnCommandRepository.finalize(
        documentId: draft.id,
        localDocumentNumber: draft.documentNumber,
        godownId: godownId ?? input.godownId,
        payment: payment,
      );
      return (await _returnCommandRepository.getDocument(draft.id)) ?? draft;
    }

    final draft = await saveDocumentDraft(input, itemNameToId: itemNameToId);
    await _repository.finalizeDocument(
      draft.id,
      godownId: godownId ?? input.godownId,
    );
    return _repository.getDocument(draft.id);
  }

  Future<SaleDocumentFormState> loadSaleDocumentForm(String documentId) async {
    SalesDocumentDto? document;
    if (_returnCommandRepository != null) {
      document = await _returnCommandRepository.getDocument(documentId);
    }
    if (document == null && _commandRepository != null) {
      document = await _commandRepository.getDocument(documentId);
    }

    if (document == null) {
      try {
        document = await _repository.getDocument(documentId);
      } on DioException catch (error) {
        throw mapSalesError(error);
      }
    }

    final partyNames = await _partyNameMap();
    final partyName = document.partyId != null
        ? (partyNames[document.partyId] ?? '')
        : '';

    final date = DateTimeUtils.parseApiDateTime(document.documentDate);
    final items = _linesToSaleLineItems(document.lines);

    return SaleDocumentFormState(
      isFormOpen: true,
      documentId: document.id,
      partyId: document.partyId,
      party: partyName,
      refNo: document.documentNumber ?? '',
      invoiceDate: DateTime(date.year, date.month, date.day),
      invoiceTime: TimeOfDay.fromDateTime(date),
      description: document.notes ?? '',
      items: items,
    );
  }

  List<SaleLineItem> _linesToSaleLineItems(List<SalesDocumentLineDto> lines) {
    if (lines.isEmpty) {
      return [SaleLineItem.empty(id: newDocumentLineId())];
    }

    return lines.map((line) {
      final qty = double.tryParse(line.quantity) ?? 0;
      final price = double.tryParse(line.unitPrice) ?? 0;
      final discountAmount = double.tryParse(line.discountAmount) ?? 0;
      final lineSubtotal = qty * price;
      final discountPercent = lineSubtotal > 0
          ? (discountAmount / lineSubtotal) * 100
          : 0.0;
      final taxPercent = double.tryParse(line.taxRate) ?? 0;

      return SaleLineItem(
        id: line.id,
        serverLineId: line.id,
        itemId: line.itemId,
        qty: qty,
        unit: line.unit,
        pricePerUnit: price,
        discountPercent: discountPercent,
        taxPercent: taxPercent,
      );
    }).toList();
  }

  Future<SalesDocumentDto> _syncGenericDocumentHeader(
    SalesDocumentDraftInput input,
  ) async {
    await _repository.updateDocument(
      input.documentId!,
      UpdateSalesDocumentRequest(
        partyId: input.partyId,
        documentDate: _apiDocumentDate(input),
        notes: input.notes?.trim().isEmpty ?? true ? null : input.notes,
      ),
    );
    return _repository.getDocument(input.documentId!);
  }

  Future<void> _syncLinesGeneric({
    required String documentId,
    required List<SaleLineItem> items,
    required Map<String, String> itemNameToId,
    required List<SalesDocumentLineDto> existingLines,
    String taxOption = 'NONE',
  }) async {
    final existingIds = existingLines.map((line) => line.id).toSet();
    final keptServerIds = <String>{};

    for (var i = 0; i < items.length; i++) {
      final line = items[i];
      if (line.qty <= 0 && line.itemName.trim().isEmpty) continue;

      final itemId = line.itemId ?? itemNameToId[line.itemName.trim()];
      if (itemId == null && line.itemName.trim().isNotEmpty) {
        throw SalesException('Item not found: ${line.itemName}');
      }
      if (itemId == null) continue;

      // Sanitize unit: backend requires min(1) max(50), rejects 'NONE'/empty.
      final rawUnit = line.unit.trim();
      final sanitizedUnit = (rawUnit.isEmpty || rawUnit.toUpperCase() == 'NONE')
          ? 'Pcs'
          : rawUnit;

      final taxPercent = effectiveSaleLineTaxPercent(
        taxOption: taxOption,
        lineTaxPercent: line.taxPercent,
      );

      final request = CreateSalesLineRequest(
        itemId: itemId,
        quantity: line.qty.toStringAsFixed(4),
        unit: sanitizedUnit,
        unitPrice: line.pricePerUnit.toStringAsFixed(4),
        discountAmount:
            (line.qty * line.pricePerUnit * (line.discountPercent / 100))
                .toStringAsFixed(4),
        taxRate: taxPercent.toStringAsFixed(4),
        taxType: taxPercent > 0 ? 'cgst_sgst' : 'none',
        sortOrder: i,
      );

      final serverLineId = resolveSaleServerLineId(
        localServerLineId: line.serverLineId,
        sortOrder: i,
        itemId: itemId,
        existingLines: existingLines,
        keptServerIds: keptServerIds,
      );

      if (serverLineId != null) {
        keptServerIds.add(serverLineId);
        await _repository.updateLine(
          documentId,
          serverLineId,
          UpdateSalesLineRequest(
            itemId: itemId,
            quantity: request.quantity,
            unit: sanitizedUnit,
            unitPrice: request.unitPrice,
            discountAmount: request.discountAmount,
            taxRate: request.taxRate,
            taxType: request.taxType,
            sortOrder: i,
          ),
        );
      } else {
        final created = await _repository.addLine(documentId, request);
        keptServerIds.add(created.id);
      }
    }

    for (final existingId in existingIds) {
      if (!keptServerIds.contains(existingId)) {
        await _repository.deleteLine(documentId, existingId);
      }
    }
  }

  Future<CreateAndFinalizeSaleResult> createAndFinalizeSale(
    AddSaleFormState form, {
    required String? partyId,
    required Map<String, String> itemNameToId,
    String? godownId,
    bool isGstFormal = true,
    double loyaltyPointsRedeemed = 0,
    String? shortPaymentHandling,
    double? shortfallAmount,
  }) async {
    if (partyId == null || partyId.isEmpty) {
      throw const SalesException('Party is required');
    }

    final receivedAmount = form.saleType == SaleType.cash
        ? form.paymentAmount
        : (form.receivedEnabled ? form.receivedAmount : 0);

    if (_commandRepository != null) {
      final draft = await saveDraft(
        form.copyWith(partyId: partyId, godownId: godownId),
        itemNameToId: itemNameToId,
      );

      FinalizeSalePaymentCommand? payment;
      if (receivedAmount > 0) {
        payment = FinalizeSalePaymentCommand(
          amount: receivedAmount.toStringAsFixed(4),
          paymentMode: SalesPaymentModes.toApi(form.paymentType),
          shortPaymentHandling: shortPaymentHandling,
          shortfallAmount: shortfallAmount != null && shortfallAmount > 0
              ? shortfallAmount.toStringAsFixed(4)
              : null,
        );
      }

      await _commandRepository.finalize(
        documentId: draft.id,
        localDocumentNumber: draft.documentNumber,
        godownId: godownId ?? form.godownId,
        payment: payment,
      );

      final finalized = await _commandRepository.getDocument(draft.id);
      return CreateAndFinalizeSaleResult(
        document: finalized ?? draft,
      );
    }

    try {
      final draft = await saveDraft(
        form.copyWith(partyId: partyId, godownId: godownId),
        itemNameToId: itemNameToId,
      );
      final finalizeResult = await _repository.finalizeDocument(
        draft.id,
        godownId: godownId ?? form.godownId,
        loyaltyPointsRedeemed: loyaltyPointsRedeemed,
      );
      final finalized = await _repository.getDocument(draft.id);

      if (receivedAmount > 0) {
        final paymentMode = SalesPaymentModes.toApi(form.paymentType);
        final routeToHiddenLedger =
            shortPaymentHandling == 'unrecovered' &&
            shortfallAmount != null &&
            shortfallAmount > 0;
        final payableTotal = form.invoiceTotal;
        final allocationAmount = routeToHiddenLedger
            ? payableTotal
            : receivedAmount;

        await _repository.createPayment(
          CreatePaymentRequest(
            partyId: partyId,
            direction: 'received',
            amount: receivedAmount.toStringAsFixed(4),
            paymentMode: paymentMode,
            source: 'document_finalize',
            paymentDate: DateTimeUtils.toApiIso(
              DateTimeUtils.mergeDateAndTime(
                date: form.invoiceDate,
                time: form.invoiceTime,
              ),
            ),
            shortPaymentHandling: shortPaymentHandling,
            shortfallAmount: shortfallAmount != null && shortfallAmount > 0
                ? shortfallAmount.toStringAsFixed(4)
                : null,
            allocations: [
              PaymentAllocationRequest(
                salesDocumentId: finalized.id,
                allocatedAmount: allocationAmount.toStringAsFixed(4),
              ),
            ],
          ),
        );
      }

      return CreateAndFinalizeSaleResult(
        document: finalized,
        loyalty: finalizeResult.loyalty,
        earnedLoyaltyPoints: finalizeResult.loyalty?.earnedPointsInt ?? 0,
      );
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
  }

  Future<void> deleteDraft(String documentId) async {
    if (_commandRepository != null) {
      final local = await _commandRepository.getDocument(documentId);
      if (local != null &&
          local.documentType == SalesDocumentType.taxInvoice.apiValue) {
        await _commandRepository.deleteDraft(documentId);
        return;
      }
    }

    try {
      await _repository.deleteDocument(documentId);
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
  }

  Future<void> cancelSale(String documentId) async {
    try {
      await _repository.cancelDocument(documentId);
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
  }

  Future<SalesDocumentDto> convertDocument(
    String documentId, {
    required String targetType,
    bool applyGst = false,
  }) async {
    try {
      return await _repository.convertDocument(
        documentId,
        ConvertSalesDocumentRequest(
          targetType: targetType,
          applyGst: applyGst,
        ),
      );
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
  }

  Future<SalesDocumentDto> finalizeDraft(
    String documentId, {
    String? godownId,
  }) async {
    if (_commandRepository != null) {
      final local = await _commandRepository.getDocument(documentId);
      if (local != null &&
          local.documentType == SalesDocumentType.taxInvoice.apiValue &&
          local.status == 'draft') {
        await _commandRepository.finalize(
          documentId: documentId,
          localDocumentNumber: local.documentNumber,
          godownId: godownId,
        );
        final finalized = await _commandRepository.getDocument(documentId);
        return finalized ?? local;
      }
    }

    try {
      await _repository.finalizeDocument(documentId, godownId: godownId);
      return _repository.getDocument(documentId);
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
  }

  Future<PaymentInModel> createPayment(CreatePaymentRequest request) async {
    try {
      final payment = await _repository.createPayment(request);
      final partyNames = await _partyNameMap();
      return SalesDocumentMapper.toPaymentInModel(
        payment,
        partyName: partyNames[payment.partyId] ?? '',
      );
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
  }

  Future<void> deletePayment(String paymentId) async {
    try {
      await _repository.deletePayment(paymentId);
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
  }

  Future<List<PaymentAllocationRequest>> buildFifoAllocations({
    required String partyId,
    required double amount,
  }) async {
    if (amount <= 0) return const [];

    final page = await fetchInvoicesPage(
      SalesDocumentListQuery(
        documentType: 'tax_invoice',
        status: 'finalized',
        partyId: partyId,
        limit: 100,
        order: 'asc',
      ),
    );

    var remaining = amount;
    final allocations = <PaymentAllocationRequest>[];

    for (final invoice in page.items) {
      if (remaining <= 0) break;
      if (invoice.balance <= 0) continue;

      final allocate = remaining < invoice.balance
          ? remaining
          : invoice.balance;
      allocations.add(
        PaymentAllocationRequest(
          salesDocumentId: invoice.id,
          allocatedAmount: allocate.toStringAsFixed(4),
        ),
      );
      remaining -= allocate;
    }

    return allocations;
  }

  Future<double> fetchPartyBalanceDue(String partyId) async {
    final page = await fetchInvoicesPage(
      SalesDocumentListQuery(
        status: 'finalized',
        partyId: partyId,
        limit: 100,
      ),
    );
    return page.items.fold<double>(
      0,
      (sum, invoice) => sum + (invoice.balance > 0 ? invoice.balance : 0),
    );
  }

  String? _apiDocumentDate(SalesDocumentDraftInput input) {
    final date = input.documentDate;
    if (date == null) return null;
    return DateTimeUtils.toApiIso(
      DateTimeUtils.mergeDateAndTime(
        date: date,
        time: input.documentTime,
      ),
    );
  }
}
