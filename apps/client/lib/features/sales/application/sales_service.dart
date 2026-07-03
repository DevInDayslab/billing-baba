import 'package:billing_baba/core/providers/api_client_provider.dart';
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
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'sales_error_mapper.dart' show SalesException, SalesOfflineException;

part 'sales_service.g.dart';

@Riverpod(keepAlive: true)
Future<SalesService> salesService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return SalesService(
    repository: SalesRepository(
      remote: SalesRemoteDataSource(api.dio),
      local: const SalesLocalDataSource(),
    ),
  );
}

class SalesService {
  SalesService({required this._repository});

  final SalesRepository _repository;

  Future<List<SaleInvoiceModel>> fetchInvoices({
    SalesDocumentListQuery? query,
  }) async {
    try {
      final response = await _repository.listDocuments(
        query ??
            const SalesDocumentListQuery(
              documentType: 'tax_invoice',
              limit: 100,
            ),
      );
      return response.documents
          .map(SalesDocumentMapper.toInvoiceModel)
          .toList();
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
  }

  Future<List<SaleInvoiceModel>> fetchDocumentsByType(
    SalesDocumentType type, {
    int limit = 100,
  }) async {
    try {
      final response = await _repository.listDocuments(
        SalesDocumentListQuery(documentType: type.apiValue, limit: limit),
      );
      return response.documents
          .map(SalesDocumentMapper.toInvoiceModel)
          .toList();
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
      final document = await _repository.createDocument(
        CreateSalesDocumentRequest(
          documentType: SalesDocumentType.taxInvoice.apiValue,
          documentSeries: SalesConstants.defaultDocumentSeries,
          partyId: partyId,
          isGstFormal: isGstFormal,
          documentDate: form.invoiceDate?.toUtc().toIso8601String(),
          notes: form.description.trim().isEmpty ? null : form.description,
        ),
      );

      for (var i = 0; i < form.items.length; i++) {
        final line = form.items[i];
        if (line.qty <= 0 || line.itemName.trim().isEmpty) continue;

        final itemId = line.itemId ?? itemNameToId[line.itemName.trim()];
        if (itemId == null) {
          throw SalesException('Item not found: ${line.itemName}');
        }

        await _repository.addLine(
          document.id,
          CreateSalesLineRequest(
            itemId: itemId,
            quantity: line.qty.toStringAsFixed(4),
            unit: line.unit,
            unitPrice: line.pricePerUnit.toStringAsFixed(4),
            discountAmount: (line.qty *
                    line.pricePerUnit *
                    (line.discountPercent / 100))
                .toStringAsFixed(4),
            taxRate: line.taxPercent.toStringAsFixed(4),
            taxType: line.taxPercent > 0 ? 'cgst_sgst' : 'none',
            sortOrder: i,
          ),
        );
      }

      return _repository.finalizeDocument(document.id, godownId: godownId);
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
  }

  Future<List<PaymentInModel>> fetchPayments({
    PaymentListQuery? query,
  }) async {
    try {
      final response = await _repository.listPayments(
        query ??
            const PaymentListQuery(direction: 'received', limit: 100),
      );
      return response.payments
          .map(SalesDocumentMapper.toPaymentInModel)
          .toList();
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
  }

  Future<PaymentInModel> createPayment(CreatePaymentRequest request) async {
    try {
      final payment = await _repository.createPayment(request);
      return SalesDocumentMapper.toPaymentInModel(payment);
    } on DioException catch (error) {
      throw mapSalesError(error);
    }
  }
}
