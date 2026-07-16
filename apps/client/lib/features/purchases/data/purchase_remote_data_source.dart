import 'package:billing_baba/core/constants/app_constants.dart';
import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_dto.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_document_parse_dto.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_requests.dart';
import 'package:dio/dio.dart';

class PurchaseRemoteDataSource {
  PurchaseRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedPurchaseDocumentsDto> listDocuments(
    PurchaseDocumentListQuery query,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.purchaseDocuments,
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedPurchaseDocumentsDto.fromJson(response.data ?? {});
  }

  Future<PurchaseDocumentDto> getDocument(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.purchaseDocument(id),
    );
    return PurchaseDocumentDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<PurchaseDocumentDto> createDocument(
    CreatePurchaseDocumentRequest request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.purchaseDocuments,
      data: request.toJson(),
    );
    return PurchaseDocumentDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<PurchaseDocumentDto> updateDocument(
    String id,
    UpdatePurchaseDocumentRequest request,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.purchaseDocument(id),
      data: request.toJson(),
    );
    return PurchaseDocumentDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<void> deleteDocument(String id) async {
    await _dio.delete<void>(ApiEndpoints.purchaseDocument(id));
  }

  Future<PurchaseDocumentDto> finalizeDocument(
    String id, {
    String? godownId,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.purchaseDocumentFinalize(id),
      data: {'godown_id': ?godownId},
    );
    return getDocument(id);
  }

  Future<PurchaseDocumentDto> cancelDocument(String id) async {
    await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.purchaseDocumentCancel(id),
    );
    return getDocument(id);
  }

  Future<PurchaseDocumentDto> convertDocument(
    String id,
    ConvertPurchaseDocumentRequest request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.purchaseDocumentConvert(id),
      data: request.toJson(),
    );
    return PurchaseDocumentDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<List<PurchaseBillPaymentHistoryEntry>> getPaymentHistory(
    String documentId,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.purchaseDocumentPaymentHistory(documentId),
    );
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(PurchaseBillPaymentHistoryEntry.fromJson)
        .toList();
  }

  Future<PurchaseDocumentLineDto> addLine(
    String documentId,
    CreatePurchaseLineRequest request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.purchaseDocumentLines(documentId),
      data: request.toJson(),
    );
    return PurchaseDocumentLineDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<PurchaseDocumentLineDto> updateLine(
    String documentId,
    String lineId,
    UpdatePurchaseLineRequest request,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.purchaseDocumentLine(documentId, lineId),
      data: request.toJson(),
    );
    return PurchaseDocumentLineDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<void> deleteLine(String documentId, String lineId) async {
    await _dio.delete<void>(
      ApiEndpoints.purchaseDocumentLine(documentId, lineId),
    );
  }

  Future<PaginatedPaymentsDto> listPayments(PaymentListQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.payments,
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedPaymentsDto.fromJson(response.data ?? {});
  }

  Future<PaymentDto> createPayment(CreatePaymentRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.payments,
      data: request.toJson(),
    );
    return PaymentDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<PurchaseDocumentParseDto> parseDocument({
    required String filename,
    required List<int> bytes,
    String? mimeType,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
      ),
    });

    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.purchaseParseDocument,
      data: formData,
      options: Options(
        sendTimeout: AppConstants.documentParseTimeout,
        receiveTimeout: AppConstants.documentParseTimeout,
      ),
    );

    return PurchaseDocumentParseDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }
}
