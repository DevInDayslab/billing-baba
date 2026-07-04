import 'package:billing_baba/features/purchases/data/purchase_local_data_source.dart';
import 'package:billing_baba/features/purchases/data/purchase_remote_data_source.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_dto.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';

class PurchaseRepository {
  PurchaseRepository({
    required this._remote,
    this._local,
  });

  final PurchaseRemoteDataSource _remote;
  // ignore: unused_field
  final PurchaseLocalDataSource? _local;

  Future<PaginatedPurchaseDocumentsDto> listDocuments(
    PurchaseDocumentListQuery query,
  ) => _remote.listDocuments(query);

  Future<PurchaseDocumentDto> getDocument(String id) =>
      _remote.getDocument(id);

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
}
