import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/sales/models/dto/sales_document_dto.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:dio/dio.dart';

class SalesRemoteDataSource {
  SalesRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedSalesDocumentsDto> listDocuments(
    SalesDocumentListQuery query,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.salesDocuments,
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedSalesDocumentsDto.fromJson(response.data ?? {});
  }

  Future<SalesDocumentDto> getDocument(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.salesDocument(id),
    );
    return SalesDocumentDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<SalesDocumentDto> createDocument(
    CreateSalesDocumentRequest request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.salesDocuments,
      data: request.toJson(),
    );
    return SalesDocumentDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<SalesDocumentDto> updateDocument(
    String id,
    UpdateSalesDocumentRequest request,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.salesDocument(id),
      data: request.toJson(),
    );
    return SalesDocumentDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<void> deleteDocument(String id) async {
    await _dio.delete<void>(ApiEndpoints.salesDocument(id));
  }

  Future<SalesDocumentDto> cancelDocument(String id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.salesDocumentCancel(id),
    );
    return SalesDocumentDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<SalesDocumentDto> finalizeDocument(
    String id, {
    String? godownId,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.salesDocumentFinalize(id),
      data: {'godown_id': ?godownId},
    );
    return getDocument(id);
  }

  Future<SalesDocumentLineDto> addLine(
    String documentId,
    CreateSalesLineRequest request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.salesDocumentLines(documentId),
      data: request.toJson(),
    );
    return SalesDocumentLineDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<SalesDocumentLineDto> updateLine(
    String documentId,
    String lineId,
    UpdateSalesLineRequest request,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.salesDocumentLine(documentId, lineId),
      data: request.toJson(),
    );
    return SalesDocumentLineDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<void> deleteLine(String documentId, String lineId) async {
    await _dio.delete<void>(
      ApiEndpoints.salesDocumentLine(documentId, lineId),
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

  Future<PaymentDto> addPaymentAllocation(
    String paymentId,
    PaymentAllocationRequest request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.paymentAllocations(paymentId),
      data: request.toJson(),
    );
    return PaymentDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<SalesDocumentDto> convertDocument(
    String id,
    ConvertSalesDocumentRequest request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.salesDocumentConvert(id),
      data: request.toJson(),
    );
    return SalesDocumentDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }
}
