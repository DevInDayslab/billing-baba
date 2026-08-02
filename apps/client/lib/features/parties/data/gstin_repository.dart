import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/parties/models/gstin_verification_response.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gstin_repository.g.dart';

@Riverpod(keepAlive: true)
Future<GstinRepository> gstinRepository(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return GstinRepository(api.dio);
}

class GstinRepository {
  GstinRepository(this._dio);

  final Dio _dio;

  Future<GstinVerificationResponse> verify(String gstin) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.gstinVerify,
      data: {'gstin': gstin},
    );
    final envelope = response.data?['data'];
    if (envelope is! Map<String, dynamic>) {
      throw const FormatException('Invalid GSTIN verification response');
    }
    return GstinVerificationResponse.fromJson(envelope);
  }
}
