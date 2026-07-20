import 'dart:typed_data';

import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/generated_documents/models/generated_document_dto.dart';
import 'package:dio/dio.dart';

class GeneratedDocumentsRemoteDataSource {
  GeneratedDocumentsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<GeneratedDocumentDto?> lookup({
    required String documentKind,
    required String sourceType,
    required String sourceId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.generatedDocumentsLookup,
      queryParameters: {
        'document_kind': documentKind,
        'source_type': sourceType,
        'source_id': sourceId,
      },
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) return null;
    return GeneratedDocumentDto.fromJson(data);
  }

  Future<GeneratedDocumentDto> ensure({
    required String documentKind,
    required String sourceType,
    required String sourceId,
    String? contentBase64,
    String? fileName,
    bool forceRegenerate = false,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.generatedDocumentsEnsure,
      data: {
        'document_kind': documentKind,
        'source_type': sourceType,
        'source_id': sourceId,
        'content_base64': ?contentBase64,
        'file_name': ?fileName,
        if (forceRegenerate) 'force_regenerate': true,
      },
    );
    return GeneratedDocumentDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<GeneratedDocumentDownloadUrlDto> getDownloadUrl(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.generatedDocumentUrl(id),
    );
    return GeneratedDocumentDownloadUrlDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<Uint8List> downloadBytes(String url) async {
    final response = await _dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data ?? const []);
  }
}
