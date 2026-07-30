import 'package:billing_baba/features/loyalty/models/loyalty_dto.dart';
import 'package:billing_baba/features/sales/data/sales_local_data_source.dart';
import 'package:billing_baba/features/sales/data/sales_remote_data_source.dart';
import 'package:billing_baba/features/sales/models/dto/sales_document_dto.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:dio/dio.dart';

class SalesRepository {
  SalesRepository({
    required this._remote,
    this._local,
  });

  final SalesRemoteDataSource _remote;
  final SalesLocalDataSource? _local;

  Future<PaginatedSalesDocumentsDto> listDocuments(
    SalesDocumentListQuery query,
  ) =>
      _remote.listDocuments(query);

  /// Local Drift first, then API. Printing and detail views must not block on network.
  Future<SalesDocumentDto> getDocument(String id) async {
    final local = _local;
    if (local != null) {
      final cached = await local.getDocument(id);
      if (cached != null) return cached;
    }

    try {
      return await _remote.getDocument(id);
    } on DioException {
      if (local != null) {
        final cached = await local.getDocument(id);
        if (cached != null) return cached;
      }
      rethrow;
    }
  }

  Future<SalesDocumentDto> createDocument(CreateSalesDocumentRequest request) =>
      _remote.createDocument(request);

  Future<SalesDocumentDto> updateDocument(
    String id,
    UpdateSalesDocumentRequest request,
  ) => _remote.updateDocument(id, request);

  Future<void> deleteDocument(String id) => _remote.deleteDocument(id);

  Future<SalesDocumentDto> cancelDocument(String id) =>
      _remote.cancelDocument(id);

  Future<FinalizeSalesDocumentResult> finalizeDocument(
    String id, {
    String? godownId,
    double loyaltyPointsRedeemed = 0,
  }) => _remote.finalizeDocument(
    id,
    godownId: godownId,
    loyaltyPointsRedeemed: loyaltyPointsRedeemed,
  );

  Future<SalesDocumentLineDto> addLine(
    String documentId,
    CreateSalesLineRequest request,
  ) => _remote.addLine(documentId, request);

  Future<SalesDocumentLineDto> updateLine(
    String documentId,
    String lineId,
    UpdateSalesLineRequest request,
  ) => _remote.updateLine(documentId, lineId, request);

  Future<void> deleteLine(String documentId, String lineId) =>
      _remote.deleteLine(documentId, lineId);

  Future<PaginatedPaymentsDto> listPayments(PaymentListQuery query) =>
      _remote.listPayments(query);

  Future<PaymentDto> createPayment(CreatePaymentRequest request) =>
      _remote.createPayment(request);

  Future<PaymentDto> addPaymentAllocation(
    String paymentId,
    PaymentAllocationRequest request,
  ) => _remote.addPaymentAllocation(paymentId, request);

  Future<PaymentDto> getPayment(String id) => _remote.getPayment(id);

  Future<PaymentDto> updatePayment(
    String id,
    UpdatePaymentRequest request,
  ) => _remote.updatePayment(id, request);

  Future<void> deletePayment(String id) => _remote.deletePayment(id);

  Future<SalesDocumentDto> convertDocument(
    String id,
    ConvertSalesDocumentRequest request,
  ) => _remote.convertDocument(id, request);

  Future<SalesDocumentDto> cloneWithAlternatives(
    String id,
    List<ItemReplacement> replacements,
  ) => _remote.cloneWithAlternatives(id, replacements);
}
