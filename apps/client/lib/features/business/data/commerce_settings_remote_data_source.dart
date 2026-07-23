import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/business/models/commerce_settings_model.dart';
import 'package:dio/dio.dart';

class CommerceSettingsRemoteDataSource {
  CommerceSettingsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<CommerceSettingsModel> fetch() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.businessCommerceSettings,
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid commerce settings response');
    }
    return CommerceSettingsModel.fromJson(data);
  }

  Future<CommerceSettingsModel> update(Map<String, dynamic> body) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.businessCommerceSettings,
      data: body,
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid commerce settings response');
    }
    return CommerceSettingsModel.fromJson(data);
  }
}
