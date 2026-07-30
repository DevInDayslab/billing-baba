import 'package:billing_baba/features/purchases/data/purchase_local_data_source.dart';
import 'package:billing_baba/features/purchases/data/purchase_remote_data_source.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_dto.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_parse_dto.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';
import 'package:dio/dio.dart';

class PurchaseRepository {
  PurchaseRepository({
    required this._remote,
    this._local,
  });

  final PurchaseRemoteDataSource _remote;
  final PurchaseLocalDataSource? _local;

  Future<PaginatedPurchaseDocumentsDto> listDocuments(
    PurchaseDocumentListQuery query,
  ) => _remote.listDocuments(query);

  /// Local Drift first, then API. Printing must work offline for synced documents.
  Future<PurchaseDocumentDto> getDocument(String id) async {
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

  Future<PurchaseDocumentDto> createDocument(
    CreatePurchaseDocumentRequest request,
  ) => _remote.createDocument(request);

  Future<PurchaseDocumentDto> updateDocument(
    String id,
    UpdatePurchaseDocumentRequest request,
  ) => _remote.updateDocument(id, request);

  Future<void> deleteDocument(String id) => _remote.deleteDocument(id);

  Future<PurchaseDocumentDto> finalizeDocument(
    String id, {
    String? godownId,
  }) => _remote.finalizeDocument(id, godownId: godownId);

  Future<PurchaseDocumentDto> cancelDocument(String id) =>
      _remote.cancelDocument(id);

  Future<PurchaseDocumentDto> convertDocument(
    String id,
    ConvertPurchaseDocumentRequest request,
  ) => _remote.convertDocument(id, request);

  Future<List<PurchaseBillPaymentHistoryEntry>> getPaymentHistory(
    String documentId,
  ) => _remote.getPaymentHistory(documentId);

  Future<PurchaseDocumentLineDto> addLine(
    String documentId,
    CreatePurchaseLineRequest request,
  ) => _remote.addLine(documentId, request);

  Future<PurchaseDocumentLineDto> updateLine(
    String documentId,
    String lineId,
    UpdatePurchaseLineRequest request,
  ) => _remote.updateLine(documentId, lineId, request);

  Future<void> deleteLine(String documentId, String lineId) =>
      _remote.deleteLine(documentId, lineId);

  Future<PaginatedPaymentsDto> listPayments(PaymentListQuery query) =>
      _remote.listPayments(query);

  Future<PaymentDto> createPayment(CreatePaymentRequest request) =>
      _remote.createPayment(request);

  Future<PurchaseDocumentParseDto> parseDocument({
    required String filename,
    required List<int> bytes,
    String? mimeType,
  }) => _remote.parseDocument(
    filename: filename,
    bytes: bytes,
    mimeType: mimeType,
  );
}
