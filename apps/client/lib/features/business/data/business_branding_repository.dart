import 'dart:typed_data';

import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/core/storage/media_upload_client.dart';
import 'package:dio/dio.dart';

class BusinessBrandingRepository {
  BusinessBrandingRepository(this._dio) : _uploadClient = MediaUploadClient(_dio);

  final Dio _dio;
  final MediaUploadClient _uploadClient;

  Future<Map<String, dynamic>> uploadLogo({
    required Uint8List bytes,
    required String mimeType,
  }) =>
      _uploadClient.upload(
        endpoint: ApiEndpoints.businessLogo,
        bytes: bytes,
        mimeType: mimeType,
      );

  Future<void> deleteLogo() => _dio.delete<void>(ApiEndpoints.businessLogo);

  Future<Map<String, dynamic>> uploadSignature({
    required Uint8List bytes,
    required String mimeType,
  }) =>
      _uploadClient.upload(
        endpoint: ApiEndpoints.businessSignature,
        bytes: bytes,
        mimeType: mimeType,
      );

  Future<void> deleteSignature() =>
      _dio.delete<void>(ApiEndpoints.businessSignature);

  Future<Map<String, dynamic>> uploadStamp({
    required Uint8List bytes,
    required String mimeType,
  }) =>
      _uploadClient.upload(
        endpoint: ApiEndpoints.businessStamp,
        bytes: bytes,
        mimeType: mimeType,
      );

  Future<void> deleteStamp() => _dio.delete<void>(ApiEndpoints.businessStamp);

  Future<Map<String, dynamic>> uploadUpiQr({
    required Uint8List bytes,
    required String mimeType,
  }) =>
      _uploadClient.upload(
        endpoint: ApiEndpoints.businessUpiQr,
        bytes: bytes,
        mimeType: mimeType,
      );

  Future<void> deleteUpiQr() => _dio.delete<void>(ApiEndpoints.businessUpiQr);
}

class AccountAvatarRepository {
  AccountAvatarRepository(this._dio) : _uploadClient = MediaUploadClient(_dio);

  final Dio _dio;
  final MediaUploadClient _uploadClient;

  Future<Map<String, dynamic>> uploadAvatar({
    required Uint8List bytes,
    required String mimeType,
  }) =>
      _uploadClient.upload(
        endpoint: ApiEndpoints.authAvatar,
        bytes: bytes,
        mimeType: mimeType,
      );

  Future<void> deleteAvatar() => _dio.delete<void>(ApiEndpoints.authAvatar);
}
