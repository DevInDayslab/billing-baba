import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/business/models/business_profile_model.dart';
import 'package:billing_baba/features/business/models/create_business_request.dart';
import 'package:billing_baba/features/business/utils/business_profile_debug_log.dart';
import 'package:dio/dio.dart';

class BusinessRepository {
  BusinessRepository(this._dio);

  final Dio _dio;

  Future<BusinessProfileModel> getBusinessProfile() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.businessProfile,
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid business profile response',
      );
    }
    return BusinessProfileModel.fromJson(data);
  }

  Future<BusinessProfileModel> updateBusinessProfile(
    UpdateBusinessProfileRequest request,
  ) async {
    BusinessProfileDebugLog.log(
      'PUT ${ApiEndpoints.businessProfile} body=${request.toJson()}',
    );

    final response = await _dio.put<Map<String, dynamic>>(
      ApiEndpoints.businessProfile,
      data: request.toJson(),
    );

    BusinessProfileDebugLog.log(
      'PUT ${ApiEndpoints.businessProfile} status=${response.statusCode}',
    );

    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid update business profile response',
      );
    }
    return BusinessProfileModel.fromJson(data);
  }

  Future<List<BusinessDetailDto>> listBusinesses() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.businesses,
    );
    final data = response.data?['data'];
    if (data is! List) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid businesses response',
      );
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(BusinessDetailDto.fromJson)
        .toList();
  }

  Future<BusinessDetailDto> createBusiness(
    CreateBusinessRequest request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.businesses,
      data: request.toJson(),
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid create business response',
      );
    }
    return BusinessDetailDto.fromJson(data);
  }

  Future<void> scheduleBusinessDeletion(String businessId) async {
    await _dio.delete<void>(ApiEndpoints.business(businessId));
  }

  Future<void> cancelBusinessDeletion(String businessId) async {
    await _dio.post<void>(ApiEndpoints.businessCancelDeletion(businessId));
  }
}
