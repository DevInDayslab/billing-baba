import 'dart:typed_data';

import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/shared/media/media_upload_client.dart';
import 'package:dio/dio.dart';

class ItemMediaRepository {
  ItemMediaRepository(this._dio) : _uploadClient = MediaUploadClient(_dio);

  final Dio _dio;
  final MediaUploadClient _uploadClient;

  Future<Map<String, dynamic>> uploadItemImage({
    required String itemId,
    required Uint8List bytes,
    required String mimeType,
    bool isPrimary = false,
    String? replacesImageId,
  }) =>
      _uploadClient.upload(
        endpoint: ApiEndpoints.inventoryItemImages(itemId),
        bytes: bytes,
        mimeType: mimeType,
        completeExtra: {
          if (isPrimary) 'is_primary': true,
          'replaces_image_id': ?replacesImageId,
        },
      );

  Future<void> deleteItemImage(String itemId, String imageId) =>
      _dio.delete<void>(ApiEndpoints.inventoryItemImage(itemId, imageId));

  Future<void> setPrimaryItemImage(String itemId, String imageId) =>
      _dio.patch<void>(
        ApiEndpoints.inventoryItemImage(itemId, imageId),
        data: {'is_primary': true},
      );

  Future<List<String>> reorderItemImages(
    String itemId,
    List<String> imageIds,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      ApiEndpoints.inventoryItemImagesReorder(itemId),
      data: {'image_ids': imageIds},
    );
    final data = response.data?['data'];
    if (data is! List) return imageIds;
    return data
        .whereType<Map<String, dynamic>>()
        .map((row) => row['id'] as String)
        .toList();
  }

  Future<Map<String, dynamic>> uploadRackPhoto({
    required String locationId,
    required Uint8List bytes,
    required String mimeType,
  }) =>
      _uploadClient.upload(
        endpoint: ApiEndpoints.inventoryItemLocationPhoto(locationId),
        bytes: bytes,
        mimeType: mimeType,
      );

  Future<void> deleteRackPhoto(String locationId) =>
      _dio.delete<void>(ApiEndpoints.inventoryItemLocationPhoto(locationId));
}
