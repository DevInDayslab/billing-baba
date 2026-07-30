import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/purchases/models/dto/purchase_fa_dto.dart';
import 'package:billing_baba/features/purchases/models/requests/purchase_fa_requests.dart';
import 'package:dio/dio.dart';

class PurchaseFaRemoteDataSource {
  PurchaseFaRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedPurchaseFaBatchesDto> listBatches(
    PurchaseFaListQuery query,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.fixedAssetPurchases,
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedPurchaseFaBatchesDto.fromJson(response.data ?? {});
  }

  Future<PurchaseFaBatchDto> getBatch(String batchId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.fixedAssetPurchase(batchId),
    );
    return PurchaseFaBatchDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<PurchaseFaBatchDto> createBatch(
    CreatePurchaseFaRequest request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.fixedAssetPurchases,
      data: request.toJson(),
    );
    return PurchaseFaBatchDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<PurchaseFaBatchDto> updateBatch(
    String batchId,
    UpdatePurchaseFaRequest request,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.fixedAssetPurchase(batchId),
      data: request.toJson(),
    );
    return PurchaseFaBatchDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<void> deleteBatch(String batchId) async {
    await _dio.delete<void>(ApiEndpoints.fixedAssetPurchase(batchId));
  }
}
