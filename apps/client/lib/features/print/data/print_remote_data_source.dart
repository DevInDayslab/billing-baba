import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/sales/models/dto/sales_document_dto.dart';
import 'package:dio/dio.dart';

class PrintRemoteDataSource {
  PrintRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaymentDto> getPayment(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.payment(id),
    );
    return PaymentDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }
}
