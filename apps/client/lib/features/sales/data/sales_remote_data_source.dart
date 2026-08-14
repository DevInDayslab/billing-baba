import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/loyalty/models/loyalty_dto.dart';
import 'package:billing_baba/features/sales/models/dto/pos_session_dto.dart';
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

  Future<FinalizeSalesDocumentResult> finalizeDocument(
    String id, {
    String? godownId,
    double loyaltyPointsRedeemed = 0,
  }) async {
    final payload = <String, dynamic>{
      'godown_id': ?godownId,
      if (loyaltyPointsRedeemed > 0)
        'loyalty_points_redeemed': _formatPoints(loyaltyPointsRedeemed),
    };

    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.salesDocumentFinalize(id),
      data: payload,
    );
    return FinalizeSalesDocumentResult.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  String _formatPoints(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(4);
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

  Future<PaymentDto> getPayment(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.payment(id),
    );
    return PaymentDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<PaymentDto> updatePayment(
    String id,
    UpdatePaymentRequest request,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.payment(id),
      data: request.toJson(),
    );
    return PaymentDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<void> deletePayment(String id) async {
    await _dio.delete<void>(ApiEndpoints.payment(id));
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

  Future<SalesDocumentDto> cloneWithAlternatives(
    String id,
    List<ItemReplacement> replacements,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.salesDocumentCloneWithAlternatives(id),
      data: {
        'replacements': replacements
            .map(
              (r) => {
                'original_item_id': r.originalItemId,
                'replacement_item_id': r.replacementItemId,
              },
            )
            .toList(),
      },
    );
    return SalesDocumentDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<PaginatedPosSessionsDto> listPosSessions({
    int page = 1,
    int limit = 20,
    String sort = 'started_at',
    String order = 'desc',
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.posSessions,
      queryParameters: {
        'page': page,
        'limit': limit,
        'sort': sort,
        'order': order,
      },
    );
    return PaginatedPosSessionsDto.fromJson(response.data ?? {});
  }

  Future<PosSessionDto> createPosSession({String? openingCash}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.posSessions,
      data: {
        'opening_cash': ?openingCash,
      },
    );
    return PosSessionDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<PosSessionDto> getPosSession(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.posSession(id),
    );
    return PosSessionDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<PosSessionDto> closePosSession({
    required String sessionId,
    String? closingCash,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.posSession(sessionId),
      data: {
        'ended_at': DateTime.now().toUtc().toIso8601String(),
        'closing_cash': ?closingCash,
      },
    );
    return PosSessionDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }
}
