import 'package:billing_baba/core/documents/document_line_sync.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/shared/utils/date_time_utils.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/purchases/application/purchase_error_mapper.dart';
import 'package:billing_baba/features/purchases/data/purchase_local_data_source.dart';
import 'package:billing_baba/features/purchases/data/purchase_remote_data_source.dart';
import 'package:billing_baba/features/purchases/data/purchase_repository.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_dto.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_parse_dto.dart';
import 'package:billing_baba/features/purchases/models/mappers/purchase_document_mapper.dart';
import 'package:billing_baba/features/purchases/models/payment_out_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_form_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_bill_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_document_draft_input.dart';
import 'package:billing_baba/features/purchases/models/purchase_order_model.dart';
import 'package:billing_baba/features/purchases/models/purchase_return_model.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';
import 'package:billing_baba/features/purchases/purchase_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'purchase_error_mapper.dart'
    show PurchaseException, PurchaseOfflineException;

part 'purchase_service.g.dart';

class PaginatedPurchaseBills {
  const PaginatedPurchaseBills({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  final List<PurchaseBillModel> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
}

class PaginatedPurchaseOrders {
  const PaginatedPurchaseOrders({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  final List<PurchaseOrderModel> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
}

class PaginatedPurchaseReturns {
  const PaginatedPurchaseReturns({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  final List<PurchaseReturnModel> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
}

class PaginatedPaymentOut {
  const PaginatedPaymentOut({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  final List<PaymentOutModel> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
}

class PaginatedPurchaseDocuments {
  const PaginatedPurchaseDocuments({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  final List<PurchaseDocumentRecord> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
}

@Riverpod(keepAlive: true)
Future<PurchaseService> purchaseService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  final partyService = await ref.watch(partyServiceProvider.future);
  return PurchaseService(
    repository: PurchaseRepository(
      remote: PurchaseRemoteDataSource(api.dio),
      local: const PurchaseLocalDataSource(),
    ),
    partyService: partyService,
  );
}

class PurchaseService {
  PurchaseService({
    required this._repository,
    required this._partyService,
  });

  final PurchaseRepository _repository;
  final PartyService _partyService;

  Future<Map<String, String>> _partyNameMap() async {
    final parties = await _partyService.fetchParties();
    return {for (final party in parties) party.id: party.name};
  }

  Future<PaginatedPurchaseDocuments> fetchDocumentsPage(
    PurchaseDocumentListQuery query,
  ) async {
    try {
      final partyNames = await _partyNameMap();
      final response = await _repository.listDocuments(query);
      final items = response.documents
          .map(
            (dto) => PurchaseDocumentMapper.toRecord(
              dto,
              partyName: partyNames[dto.partyId] ?? '',
            ),
          )
          .toList();

      return _paginate(items, query.page, query.limit, response.meta.total);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<PaginatedPurchaseBills> fetchBillsPage(
    PurchaseDocumentListQuery query,
  ) async {
    try {
      final partyNames = await _partyNameMap();
      final response = await _repository.listDocuments(
        query.copyWith(
          documentType: PurchaseDocumentType.purchaseBill.apiValue,
        ),
      );
      final items = response.documents
          .map(
            (dto) => PurchaseDocumentMapper.toBillModel(
              dto,
              partyName: partyNames[dto.partyId] ?? '',
            ),
          )
          .toList();

      return _paginateBills(
        items,
        query.page,
        query.limit,
        response.meta.total,
      );
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<PaginatedPurchaseOrders> fetchOrdersPage(
    PurchaseDocumentListQuery query,
  ) async {
    try {
      final partyNames = await _partyNameMap();
      final response = await _repository.listDocuments(
        query.copyWith(
          documentType: PurchaseDocumentType.purchaseOrder.apiValue,
        ),
      );
      final items = response.documents
          .map(
            (dto) => PurchaseDocumentMapper.toOrderModel(
              dto,
              partyName: partyNames[dto.partyId] ?? '',
            ),
          )
          .toList();

      return _paginateOrders(
        items,
        query.page,
        query.limit,
        response.meta.total,
      );
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<PaginatedPurchaseReturns> fetchReturnsPage(
    PurchaseDocumentListQuery query,
  ) async {
    try {
      final partyNames = await _partyNameMap();
      final response = await _repository.listDocuments(
        query.copyWith(
          documentType: PurchaseDocumentType.purchaseReturn.apiValue,
        ),
      );
      final items = response.documents
          .map(
            (dto) => PurchaseDocumentMapper.toReturnModel(
              dto,
              partyName: partyNames[dto.partyId] ?? '',
            ),
          )
          .toList();

      return _paginateReturns(
        items,
        query.page,
        query.limit,
        response.meta.total,
      );
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<PaginatedPaymentOut> fetchPaymentsPage(PaymentListQuery query) async {
    try {
      final partyNames = await _partyNameMap();
      final response = await _repository.listPayments(query);
      final items = response.payments
          .map(
            (dto) => PurchaseDocumentMapper.toPaymentOutModel(
              dto,
              partyName: partyNames[dto.partyId] ?? '',
            ),
          )
          .toList();

      final total = response.meta.total;
      final totalPages = total == 0 ? 1 : (total / query.limit).ceil();

      return PaginatedPaymentOut(
        items: items,
        currentPage: query.page,
        totalPages: totalPages,
        totalItems: total,
      );
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<AddPurchaseFormState> loadPurchaseBillForm(String documentId) async {
    return _loadForm(documentId, PurchaseDocumentType.purchaseBill);
  }

  Future<AddPurchaseFormState> loadPurchaseOrderForm(String documentId) async {
    return _loadForm(documentId, PurchaseDocumentType.purchaseOrder);
  }

  Future<AddPurchaseFormState> loadDebitNoteForm(String documentId) async {
    return _loadForm(documentId, PurchaseDocumentType.purchaseReturn);
  }

  Future<AddPurchaseFormState> _loadForm(
    String documentId,
    PurchaseDocumentType type,
  ) async {
    try {
      final document = await _repository.getDocument(documentId);
      final partyNames = await _partyNameMap();
      final partyName = partyNames[document.partyId] ?? '';
      final date = DateTime.tryParse(document.documentDate) ?? DateTime.now();
      final dueDate = document.dueDate != null
          ? DateTime.tryParse(document.dueDate!)
          : null;
      final items = _linesToPurchaseLineItems(document.lines);

      return AddPurchaseFormState(
        documentId: document.id,
        partyId: document.partyId,
        party: partyName,
        billingName: partyName,
        billNumber: document.documentNumber ?? 'Draft',
        billDate: DateTime(date.year, date.month, date.day),
        billTime: TimeOfDay.fromDateTime(date),
        dueDate: dueDate != null
            ? DateTime(dueDate.year, dueDate.month, dueDate.day)
            : null,
        description: document.notes ?? '',
        eWayBillNo: document.supplierInvoiceNumber ?? '',
        items: items,
      );
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<PurchaseDocumentDto> saveDocumentDraft(
    PurchaseDocumentDraftInput input, {
    required Map<String, String> itemNameToId,
  }) async {
    try {
      final document = input.documentId == null
          ? await _repository.createDocument(
              CreatePurchaseDocumentRequest(
                documentType: input.documentType.apiValue,
                documentSeries: input.documentSeries,
                partyId: input.partyId!,
                isGstFormal: input.isGstFormal,
                documentDate: _apiDocumentDate(input),
                dueDate: input.dueDate != null
                    ? PurchaseConstants.formatApiDate(input.dueDate!)
                    : null,
                supplierInvoiceNumber: input.supplierInvoiceNumber,
                convertedFromId: input.convertedFromId,
                notes: input.notes?.trim().isEmpty ?? true ? null : input.notes,
              ),
            )
          : await _syncDocumentHeader(input);

      await _syncLines(
        documentId: document.id,
        items: input.items,
        itemNameToId: itemNameToId,
        existingLines: document.lines,
      );

      return _repository.getDocument(document.id);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<PurchaseDocumentDto> finalizeDocumentDraft(
    PurchaseDocumentDraftInput input, {
    required Map<String, String> itemNameToId,
    String? godownId,
  }) async {
    if (input.partyId == null || input.partyId!.isEmpty) {
      throw const PurchaseException('Please select a supplier');
    }

    final draft = await saveDocumentDraft(input, itemNameToId: itemNameToId);
    return _repository.finalizeDocument(
      draft.id,
      godownId: godownId ?? input.godownId,
    );
  }

  Future<PurchaseDocumentDto> convertPurchaseOrder(String orderId) async {
    try {
      return _repository.convertDocument(
        orderId,
        const ConvertPurchaseDocumentRequest(targetType: 'purchase_bill'),
      );
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<PurchaseDocumentDto> convertBillToReturn(String billId) async {
    try {
      return _repository.convertDocument(
        billId,
        const ConvertPurchaseDocumentRequest(targetType: 'purchase_return'),
      );
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<String> duplicatePurchaseBill(String documentId) async {
    return _duplicatePurchaseDocument(
      documentId,
      PurchaseDocumentType.purchaseBill,
    );
  }

  Future<String> duplicatePurchaseOrder(String documentId) async {
    return _duplicatePurchaseDocument(
      documentId,
      PurchaseDocumentType.purchaseOrder,
    );
  }

  Future<String> duplicatePurchaseReturn(String documentId) async {
    return _duplicatePurchaseDocument(
      documentId,
      PurchaseDocumentType.purchaseReturn,
    );
  }

  Future<String> _duplicatePurchaseDocument(
    String documentId,
    PurchaseDocumentType documentType,
  ) async {
    try {
      final source = await _repository.getDocument(documentId);
      final newDoc = await _repository.createDocument(
        CreatePurchaseDocumentRequest(
          documentType: documentType.apiValue,
          documentSeries: PurchaseDocumentMapper.seriesForType(documentType),
          partyId: source.partyId,
          isGstFormal: source.isGstFormal,
          partyStateCode: source.partyStateCode,
          documentDate: DateTime.now().toUtc().toIso8601String(),
          dueDate: source.dueDate,
          notes: source.notes,
        ),
      );

      for (final line in source.lines) {
        await _repository.addLine(
          newDoc.id,
          CreatePurchaseLineRequest(
            itemId: line.itemId,
            quantity: line.quantity,
            unit: line.unit,
            unitPrice: line.unitPrice,
            discountAmount: line.discountAmount,
            taxType: line.taxType,
            taxRate: line.taxRate,
            sortOrder: line.sortOrder,
          ),
        );
      }

      return newDoc.id;
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<List<PurchaseBillPaymentHistoryEntry>> fetchPaymentHistory(
    String documentId,
  ) async {
    try {
      return _repository.getPaymentHistory(documentId);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<PurchaseDocumentParseDto> parsePurchaseDocument({
    required String filename,
    required List<int> bytes,
    String? mimeType,
  }) async {
    try {
      debugPrint(
        '[PurchaseParse] parsePurchaseDocument request filename=$filename bytes=${bytes.length}',
      );
      final result = await _repository.parseDocument(
        filename: filename,
        bytes: bytes,
        mimeType: mimeType,
      );
      debugPrint(
        '[PurchaseParse] parsePurchaseDocument response lines=${result.lines.length}',
      );
      return result;
    } on DioException catch (error, stackTrace) {
      debugPrint(
        '[PurchaseParse] parsePurchaseDocument DioException: $error\n$stackTrace',
      );
      throw mapPurchaseError(error);
    } on Object catch (error, stackTrace) {
      debugPrint(
        '[PurchaseParse] parsePurchaseDocument error: $error\n$stackTrace',
      );
      rethrow;
    }
  }

  Future<List<PurchaseBillHistoryEvent>> fetchBillHistory(
    String documentId,
  ) async {
    try {
      final document = await _repository.getDocument(documentId);
      final events = <PurchaseBillHistoryEvent>[
        PurchaseBillHistoryEvent(
          timestamp: DateTime.parse(document.createdAt).toLocal(),
          title: 'Bill created',
          subtitle: document.documentNumber ?? 'Draft',
        ),
      ];

      if (document.convertedFromId != null) {
        try {
          final source = await _repository.getDocument(
            document.convertedFromId!,
          );
          events.add(
            PurchaseBillHistoryEvent(
              timestamp: DateTime.parse(document.createdAt).toLocal(),
              title: 'Converted from purchase order',
              subtitle: source.documentNumber ?? source.id,
            ),
          );
        } catch (_) {
          events.add(
            PurchaseBillHistoryEvent(
              timestamp: DateTime.parse(document.createdAt).toLocal(),
              title: 'Converted from another document',
              subtitle: document.convertedFromId,
            ),
          );
        }
      }

      if (document.status == 'finalized') {
        events.add(
          PurchaseBillHistoryEvent(
            timestamp: DateTime.parse(document.updatedAt).toLocal(),
            title: 'Bill finalized',
            subtitle: document.documentNumber,
          ),
        );
      }

      if (document.status == 'cancelled') {
        events.add(
          PurchaseBillHistoryEvent(
            timestamp: DateTime.parse(document.updatedAt).toLocal(),
            title: 'Bill cancelled',
            subtitle: document.documentNumber,
          ),
        );
      }

      final payments = await _repository.getPaymentHistory(documentId);
      for (final payment in payments) {
        events.add(
          PurchaseBillHistoryEvent(
            timestamp: payment.paymentDate.toLocal(),
            title: 'Payment recorded',
            subtitle:
                '${payment.paymentMode} · ₹${payment.allocatedAmount.toStringAsFixed(2)}',
          ),
        );
      }

      events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return events;
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<List<PurchaseBillHistoryEvent>> fetchOrderHistory(
    String documentId,
  ) async {
    try {
      final document = await _repository.getDocument(documentId);
      final events = <PurchaseBillHistoryEvent>[
        PurchaseBillHistoryEvent(
          timestamp: DateTime.parse(document.createdAt).toLocal(),
          title: 'Order created',
          subtitle: document.documentNumber ?? 'Draft',
        ),
      ];

      if (document.status == 'finalized') {
        events.add(
          PurchaseBillHistoryEvent(
            timestamp: DateTime.parse(document.updatedAt).toLocal(),
            title: 'Order finalized',
            subtitle: document.documentNumber,
          ),
        );
      }

      if (document.status == 'converted') {
        events.add(
          PurchaseBillHistoryEvent(
            timestamp: DateTime.parse(document.updatedAt).toLocal(),
            title: 'Converted to purchase bill',
            subtitle: document.documentNumber,
          ),
        );
      }

      if (document.status == 'cancelled') {
        events.add(
          PurchaseBillHistoryEvent(
            timestamp: DateTime.parse(document.updatedAt).toLocal(),
            title: 'Order cancelled',
            subtitle: document.documentNumber,
          ),
        );
      }

      events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return events;
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<List<PurchaseBillHistoryEvent>> fetchReturnHistory(
    String documentId,
  ) async {
    try {
      final document = await _repository.getDocument(documentId);
      final events = <PurchaseBillHistoryEvent>[
        PurchaseBillHistoryEvent(
          timestamp: DateTime.parse(document.createdAt).toLocal(),
          title: 'Debit note created',
          subtitle: document.documentNumber ?? 'Draft',
        ),
      ];

      if (document.convertedFromId != null) {
        try {
          final source = await _repository.getDocument(
            document.convertedFromId!,
          );
          events.add(
            PurchaseBillHistoryEvent(
              timestamp: DateTime.parse(document.createdAt).toLocal(),
              title: 'Converted from purchase bill',
              subtitle: source.documentNumber ?? source.id,
            ),
          );
        } catch (_) {
          events.add(
            PurchaseBillHistoryEvent(
              timestamp: DateTime.parse(document.createdAt).toLocal(),
              title: 'Converted from another document',
              subtitle: document.convertedFromId,
            ),
          );
        }
      }

      if (document.status == 'finalized') {
        events.add(
          PurchaseBillHistoryEvent(
            timestamp: DateTime.parse(document.updatedAt).toLocal(),
            title: 'Debit note finalized',
            subtitle: document.documentNumber,
          ),
        );
      }

      if (document.status == 'cancelled') {
        events.add(
          PurchaseBillHistoryEvent(
            timestamp: DateTime.parse(document.updatedAt).toLocal(),
            title: 'Debit note cancelled',
            subtitle: document.documentNumber,
          ),
        );
      }

      final payments = await _repository.getPaymentHistory(documentId);
      for (final payment in payments) {
        events.add(
          PurchaseBillHistoryEvent(
            timestamp: payment.paymentDate.toLocal(),
            title: 'Payment recorded',
            subtitle:
                '${payment.paymentMode} · ₹${payment.allocatedAmount.toStringAsFixed(2)}',
          ),
        );
      }

      events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return events;
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<void> deleteDraft(String documentId) async {
    try {
      await _repository.deleteDocument(documentId);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<PurchaseDocumentDto> finalizeDraft(
    String documentId, {
    String? godownId,
  }) async {
    try {
      return _repository.finalizeDocument(documentId, godownId: godownId);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<PurchaseDocumentDto> cancelDocument(String documentId) async {
    try {
      return _repository.cancelDocument(documentId);
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<PaymentOutModel> createPayment(CreatePaymentRequest request) async {
    try {
      final payment = await _repository.createPayment(request);
      final partyNames = await _partyNameMap();
      return PurchaseDocumentMapper.toPaymentOutModel(
        payment,
        partyName: partyNames[payment.partyId] ?? '',
      );
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  /// Records an outgoing payment allocated to a finalized purchase bill.
  Future<void> recordPurchaseBillPayment({
    required String partyId,
    required String purchaseDocumentId,
    required double amount,
    required String paymentModeUi,
    String? referenceNumber,
    DateTime? paymentDate,
  }) async {
    if (amount <= 0) return;

    try {
      await _repository.createPayment(
        CreatePaymentRequest(
          partyId: partyId,
          direction: 'paid',
          amount: amount.toStringAsFixed(4),
          paymentMode: PurchasePaymentModes.toApi(paymentModeUi),
          source: 'document_finalize',
          paymentDate: paymentDate?.toUtc().toIso8601String(),
          referenceNumber: referenceNumber,
          allocations: [
            PaymentAllocationRequest(
              purchaseDocumentId: purchaseDocumentId,
              allocatedAmount: amount.toStringAsFixed(4),
            ),
          ],
        ),
      );
    } on DioException catch (error) {
      throw mapPurchaseError(error);
    }
  }

  Future<List<PaymentAllocationRequest>> buildFifoAllocations({
    required String partyId,
    required double amount,
  }) async {
    if (amount <= 0) return const [];

    final page = await fetchBillsPage(
      PurchaseDocumentListQuery(
        status: 'finalized',
        partyId: partyId,
        limit: 100,
        order: 'asc',
      ),
    );

    var remaining = amount;
    final allocations = <PaymentAllocationRequest>[];

    for (final bill in page.items) {
      if (remaining <= 0) break;
      if (bill.balanceDue <= 0) continue;

      final allocate = remaining < bill.balanceDue
          ? remaining
          : bill.balanceDue;
      allocations.add(
        PaymentAllocationRequest(
          purchaseDocumentId: bill.id,
          allocatedAmount: allocate.toStringAsFixed(4),
        ),
      );
      remaining -= allocate;
    }

    return allocations;
  }

  Future<double> fetchPartyBalanceDue(String partyId) async {
    final page = await fetchBillsPage(
      PurchaseDocumentListQuery(
        status: 'finalized',
        partyId: partyId,
        limit: 100,
      ),
    );
    return page.items.fold<double>(0, (sum, bill) => sum + bill.balanceDue);
  }

  String? _apiDocumentDate(PurchaseDocumentDraftInput input) {
    final date = input.documentDate;
    if (date == null) return null;
    return DateTimeUtils.toApiIso(
      DateTimeUtils.mergeDateAndTime(
        date: date,
        time: input.documentTime,
      ),
    );
  }

  PurchaseDocumentDraftInput draftInputFromBillForm(
    AddPurchaseFormState form, {
    required PurchaseDocumentType documentType,
  }) {
    return PurchaseDocumentDraftInput(
      documentId: form.documentId,
      partyId: form.partyId,
      documentType: documentType,
      documentSeries: PurchaseDocumentMapper.seriesForType(documentType),
      documentDate: form.billDate,
      documentTime: form.billTime,
      dueDate: form.dueDate,
      supplierInvoiceNumber: form.eWayBillNo.trim().isEmpty
          ? null
          : form.eWayBillNo.trim(),
      notes: form.description,
      godownId: form.godownId,
      items: form.items,
    );
  }

  Future<PurchaseDocumentDto> _syncDocumentHeader(
    PurchaseDocumentDraftInput input,
  ) async {
    await _repository.updateDocument(
      input.documentId!,
      UpdatePurchaseDocumentRequest(
        partyId: input.partyId,
        documentDate: _apiDocumentDate(input),
        dueDate: input.dueDate != null
            ? PurchaseConstants.formatApiDate(input.dueDate!)
            : null,
        supplierInvoiceNumber: input.supplierInvoiceNumber,
        notes: input.notes?.trim().isEmpty ?? true ? null : input.notes,
      ),
    );
    return _repository.getDocument(input.documentId!);
  }

  Future<void> _syncLines({
    required String documentId,
    required List<PurchaseLineItem> items,
    required Map<String, String> itemNameToId,
    required List<PurchaseDocumentLineDto> existingLines,
  }) async {
    final existingIds = existingLines.map((line) => line.id).toSet();
    final keptServerIds = <String>{};

    for (var i = 0; i < items.length; i++) {
      final line = items[i];
      if (line.qty <= 0 && line.itemName.trim().isEmpty) continue;

      final itemId =
          line.itemId ?? itemNameToId[line.itemName.trim().toLowerCase()];
      if (itemId == null && line.itemName.trim().isNotEmpty) {
        throw PurchaseException('Item not found: ${line.itemName}');
      }
      if (itemId == null) continue;

      final request = CreatePurchaseLineRequest(
        itemId: itemId,
        quantity: line.qty.toStringAsFixed(4),
        unit: line.unit,
        unitPrice: line.pricePerUnit.toStringAsFixed(4),
        taxRate: line.taxPercent.toStringAsFixed(4),
        taxType: line.taxPercent > 0 ? 'cgst_sgst' : 'none',
        taxInclusive: line.priceIsTaxInclusive,
        sortOrder: i,
      );

      final serverLineId = resolvePurchaseServerLineId(
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
          UpdatePurchaseLineRequest(
            itemId: itemId,
            quantity: request.quantity,
            unit: request.unit,
            unitPrice: request.unitPrice,
            taxRate: request.taxRate,
            taxType: request.taxType,
            taxInclusive: request.taxInclusive,
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

  List<PurchaseLineItem> _linesToPurchaseLineItems(
    List<PurchaseDocumentLineDto> lines,
  ) {
    if (lines.isEmpty) {
      return [PurchaseLineItem.empty(id: 'line_1')];
    }

    return lines.map((line) {
      final qty = double.tryParse(line.quantity) ?? 0;
      final price = double.tryParse(line.unitPrice) ?? 0;
      final taxPercent = double.tryParse(line.taxRate) ?? 0;

      return PurchaseLineItem(
        id: line.id,
        serverLineId: line.id,
        itemId: line.itemId,
        qty: qty,
        unit: line.unit,
        pricePerUnit: price,
        taxPercent: taxPercent,
        priceIsTaxInclusive:
            taxPercent > 0 && (double.tryParse(line.cgstAmount) ?? 0) > 0,
      );
    }).toList();
  }

  PaginatedPurchaseDocuments _paginate(
    List<PurchaseDocumentRecord> items,
    int page,
    int limit,
    int total,
  ) {
    final totalPages = total == 0 ? 1 : (total / limit).ceil();
    return PaginatedPurchaseDocuments(
      items: items,
      currentPage: page,
      totalPages: totalPages,
      totalItems: total,
    );
  }

  PaginatedPurchaseBills _paginateBills(
    List<PurchaseBillModel> items,
    int page,
    int limit,
    int total,
  ) {
    final totalPages = total == 0 ? 1 : (total / limit).ceil();
    return PaginatedPurchaseBills(
      items: items,
      currentPage: page,
      totalPages: totalPages,
      totalItems: total,
    );
  }

  PaginatedPurchaseOrders _paginateOrders(
    List<PurchaseOrderModel> items,
    int page,
    int limit,
    int total,
  ) {
    final totalPages = total == 0 ? 1 : (total / limit).ceil();
    return PaginatedPurchaseOrders(
      items: items,
      currentPage: page,
      totalPages: totalPages,
      totalItems: total,
    );
  }

  PaginatedPurchaseReturns _paginateReturns(
    List<PurchaseReturnModel> items,
    int page,
    int limit,
    int total,
  ) {
    final totalPages = total == 0 ? 1 : (total / limit).ceil();
    return PaginatedPurchaseReturns(
      items: items,
      currentPage: page,
      totalPages: totalPages,
      totalItems: total,
    );
  }
}

extension on PurchaseDocumentListQuery {
  PurchaseDocumentListQuery copyWith({
    int? page,
    int? limit,
    String? documentType,
    String? status,
    String? partyId,
    String? from,
    String? to,
    String? q,
    String? sort,
    String? order,
  }) {
    return PurchaseDocumentListQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      documentType: documentType ?? this.documentType,
      status: status ?? this.status,
      partyId: partyId ?? this.partyId,
      from: from ?? this.from,
      to: to ?? this.to,
      q: q ?? this.q,
      sort: sort ?? this.sort,
      order: order ?? this.order,
    );
  }
}
