import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/sales/models/dto/sale_fa_dto.dart';
import 'package:billing_baba/features/sales/models/requests/sale_fa_requests.dart';
import 'package:dio/dio.dart';

class SaleFaRemoteDataSource {
  SaleFaRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedSaleFaBatchesDto> listBatches(SaleFaListQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.fixedAssetSales,
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedSaleFaBatchesDto.fromJson(response.data ?? {});
  }

  Future<SaleFaBatchDto> getBatch(String batchId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.fixedAssetSale(batchId),
    );
    return SaleFaBatchDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<SaleFaBatchDto> createBatch(CreateSaleFaRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.fixedAssetSales,
      data: request.toJson(),
    );
    return SaleFaBatchDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<SaleFaBatchDto> updateBatch(
    String batchId,
    UpdateSaleFaRequest request,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.fixedAssetSale(batchId),
      data: request.toJson(),
    );
    return SaleFaBatchDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<void> deleteBatch(String batchId) async {
    await _dio.delete<void>(ApiEndpoints.fixedAssetSale(batchId));
  }
}
