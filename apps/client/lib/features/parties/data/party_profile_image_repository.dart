import 'dart:typed_data';

import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/core/storage/media_upload_client.dart';
import 'package:dio/dio.dart';

class PartyProfileImageRepository {
  PartyProfileImageRepository(this._dio)
    : _uploadClient = MediaUploadClient(_dio);

  final Dio _dio;
  final MediaUploadClient _uploadClient;

  Future<Map<String, dynamic>> uploadProfileImage({
    required String partyId,
    required Uint8List bytes,
    required String mimeType,
  }) => _uploadClient.upload(
    endpoint: ApiEndpoints.partyProfileImage(partyId),
    bytes: bytes,
    mimeType: mimeType,
  );

  Future<void> deleteProfileImage(String partyId) =>
      _dio.delete<void>(ApiEndpoints.partyProfileImage(partyId));
}
