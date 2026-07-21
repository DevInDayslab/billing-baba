import 'dart:typed_data';

import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/core/storage/media_upload_client.dart';
import 'package:dio/dio.dart';

class DocumentAttachmentRepository {
  DocumentAttachmentRepository(this._dio) : _uploadClient = MediaUploadClient(_dio);

  final Dio _dio;
  final MediaUploadClient _uploadClient;

  Future<List<Map<String, dynamic>>> list({
    required String entityType,
    required String entityId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.documentAttachments,
      queryParameters: {
        'entity_type': entityType,
        'entity_id': entityId,
      },
    );
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().toList();
  }

  Future<Map<String, dynamic>> upload({
    required String entityType,
    required String entityId,
    required Uint8List bytes,
    required String mimeType,
    required String fileName,
    String? label,
    String? replacesAttachmentId,
  }) =>
      _uploadClient.upload(
        endpoint: ApiEndpoints.documentAttachmentsFor(entityType, entityId),
        bytes: bytes,
        mimeType: mimeType,
        completeExtra: {
          'file_name': fileName,
          if (label != null) 'label': label,
          if (replacesAttachmentId != null)
            'replaces_attachment_id': replacesAttachmentId,
        },
      );

  Future<void> delete(String attachmentId) =>
      _dio.delete<void>(ApiEndpoints.documentAttachment(attachmentId));

  Future<Map<String, dynamic>> getDownloadUrl(String attachmentId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.documentAttachmentDownloadUrl(attachmentId),
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid download URL response',
      );
    }
    return data;
  }

  Future<Map<String, dynamic>> rename({
    required String attachmentId,
    required String fileName,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.documentAttachment(attachmentId),
      data: {'file_name': fileName},
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid rename response',
      );
    }
    return data;
  }
}
