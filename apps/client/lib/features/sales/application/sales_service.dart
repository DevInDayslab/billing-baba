import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/sales/application/sales_error_mapper.dart';
import 'package:billing_baba/features/sales/data/sales_local_data_source.dart';
import 'package:billing_baba/features/sales/data/sales_remote_data_source.dart';
import 'package:billing_baba/features/sales/data/sales_repository.dart';
import 'package:billing_baba/features/sales/models/dto/sales_document_dto.dart';
import 'package:billing_baba/features/sales/models/mappers/sales_document_mapper.dart';
import 'package:billing_baba/features/sales/models/payment_in_model.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_form_model.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'sales_error_mapper.dart' show SalesException, SalesOfflineException;

part 'sales_service.g.dart';

@Riverpod(keepAlive: true)
Future<SalesService> salesService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  final partyService = await ref.watch(partyServiceProvider.future);
  return SalesService(
    repository: SalesRepository(
      remote: SalesRemoteDataSource(api.dio),
      local: const SalesLocalDataSource(),
    ),
    partyService: partyService,
  );
}

class SalesService {
  SalesService({
    required this._repository,
    required this._partyService,
  });

  final SalesRepository _repository;
  final PartyService _partyService;

  Future<Map<String, String>> _partyNameMap() async {
    final parties = await _partyService.fetchParties();
    return {for (final party in parties) party.id: party.name};
  }

  Future<PaginatedSaleInvoices> fetchInvoicesPage(
    SalesDocumentListQuery query,
  ) async {
    try {
      final partyNames = await _partyNameMap();
      final response = await _repository.listDocuments(query);
      final items = response.documents
          .map(
            (dto) => SalesDocumentMapper.toInvoiceModel(
              dto,
              partyName: dto.partyId != null
                  ? (partyNames[dto.partyId] ?? '')
                  : '',
            ),
          )
          .toList();

      final total = response.meta.total;
      final totalPages = total == 0
          ? 1
          : (total / query.limit).ceil();

      return PaginatedSaleInvoices(
        items: items,
        currentPage: query.page,
        totalPages: totalPages,
        totalItems: total,
      );
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
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

  Future<PaginatedPaymentIn> fetchPaymentsPage(PaymentListQuery query) async {
    try {
      final partyNames = await _partyNameMap();
      final response = await _repository.listPayments(query);
      final items = response.payments
          .map(
            (dto) => SalesDocumentMapper.toPaymentInModel(
              dto,
              partyName: partyNames[dto.partyId] ?? '',
            ),
          )
          .toList();

      final total = response.meta.total;
      final totalPages = total == 0
          ? 1
          : (total / query.limit).ceil();

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
    try {
      final document = await _repository.getDocument(documentId);
      final partyNames = await _partyNameMap();
      final partyName = document.partyId != null
          ? (partyNames[document.partyId] ?? '')
          : '';

      final date = DateTime.tryParse(document.documentDate) ?? DateTime.now();
      final items = document.lines.isEmpty
          ? [SaleLineItem.empty(id: 'line_1')]
          : document.lines.map((line) {
              final qty = double.tryParse(line.quantity) ?? 0;
              final price = double.tryParse(line.unitPrice) ?? 0;
              final discountAmount =
                  double.tryParse(line.discountAmount) ?? 0;
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
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
  }

  Future<SalesDocumentDto> saveDraft(
    AddSaleFormState form, {
    required Map<String, String> itemNameToId,
  }) async {
    try {
      final document = form.documentId == null
          ? await _createDocumentHeader(form)
          : await _syncDocumentHeader(form);

      await _syncLines(
        documentId: document.id,
        form: form,
        itemNameToId: itemNameToId,
        existingLines: document.lines,
      );

      return _repository.getDocument(document.id);
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
  }

  Future<SalesDocumentDto> createAndFinalizeSale(
    AddSaleFormState form, {
    required String? partyId,
    required Map<String, String> itemNameToId,
    String? godownId,
    bool isGstFormal = true,
  }) async {
    if (partyId == null || partyId.isEmpty) {
      throw const SalesException('Party is required');
    }

    try {
      final draft = await saveDraft(
        form.copyWith(partyId: partyId, godownId: godownId),
        itemNameToId: itemNameToId,
      );
      return _repository.finalizeDocument(
        draft.id,
        godownId: godownId ?? form.godownId,
      );
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
  }

  Future<void> deleteDraft(String documentId) async {
    try {
      await _repository.deleteDocument(documentId);
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
  }

  Future<SalesDocumentDto> finalizeDraft(
    String documentId, {
    String? godownId,
  }) async {
    try {
      return _repository.finalizeDocument(documentId, godownId: godownId);
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

      final allocate = remaining < invoice.balance ? remaining : invoice.balance;
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
        documentType: 'tax_invoice',
        status: 'finalized',
        partyId: partyId,
        limit: 100,
      ),
    );
    return page.items.fold<double>(0, (sum, invoice) => sum + invoice.balance);
  }

  Future<SalesDocumentDto> _createDocumentHeader(AddSaleFormState form) {
    return _repository.createDocument(
      CreateSalesDocumentRequest(
        documentType: SalesDocumentType.taxInvoice.apiValue,
        documentSeries: SalesConstants.defaultDocumentSeries,
        partyId: form.partyId,
        isGstFormal: true,
        documentDate: form.invoiceDate?.toUtc().toIso8601String(),
        notes: form.description.trim().isEmpty ? null : form.description,
      ),
    );
  }

  Future<SalesDocumentDto> _syncDocumentHeader(AddSaleFormState form) async {
    await _repository.updateDocument(
      form.documentId!,
      UpdateSalesDocumentRequest(
        partyId: form.partyId,
        documentDate: form.invoiceDate?.toUtc().toIso8601String(),
        notes: form.description.trim().isEmpty ? null : form.description,
      ),
    );
    return _repository.getDocument(form.documentId!);
  }

  Future<void> _syncLines({
    required String documentId,
    required AddSaleFormState form,
    required Map<String, String> itemNameToId,
    required List<SalesDocumentLineDto> existingLines,
  }) async {
    final existingIds = existingLines.map((line) => line.id).toSet();
    final keptServerIds = <String>{};

    for (var i = 0; i < form.items.length; i++) {
      final line = form.items[i];
      if (line.qty <= 0) continue;

      final itemId = line.itemId ?? itemNameToId[line.itemName.trim()];
      if (itemId == null && line.itemName.trim().isNotEmpty) {
        throw SalesException('Item not found: ${line.itemName}');
      }
      if (itemId == null) continue;

      final request = CreateSalesLineRequest(
        itemId: itemId,
        quantity: line.qty.toStringAsFixed(4),
        unit: line.unit,
        unitPrice: line.pricePerUnit.toStringAsFixed(4),
        discountAmount: (line.qty * line.pricePerUnit * (line.discountPercent / 100))
            .toStringAsFixed(4),
        taxRate: line.taxPercent.toStringAsFixed(4),
        taxType: line.taxPercent > 0 ? 'cgst_sgst' : 'none',
        sortOrder: i,
      );

      if (line.serverLineId != null) {
        keptServerIds.add(line.serverLineId!);
        await _repository.updateLine(
          documentId,
          line.serverLineId!,
          UpdateSalesLineRequest(
            itemId: itemId,
            quantity: request.quantity,
            unit: request.unit,
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
}
