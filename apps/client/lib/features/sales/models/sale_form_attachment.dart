import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

enum AttachmentSyncStatus { local, uploading, synced, failed }

/// Attachment row for sale/purchase/expense/payment/job-work forms.
@immutable
class SaleFormAttachment {
  const SaleFormAttachment({
    required this.id,
    required this.name,
    this.path = '',
    this.remoteId,
    this.fileUrl,
    this.mimeType,
    this.isImage = false,
    this.localBytes,
    this.syncStatus = AttachmentSyncStatus.local,
    this.replacesRemoteId,
  });

  factory SaleFormAttachment.create({
    required String name,
    String path = '',
    bool isImage = false,
    String? mimeType,
    Uint8List? localBytes,
  }) {
    return SaleFormAttachment(
      id: const Uuid().v4(),
      name: name,
      path: path.isEmpty ? name : path,
      isImage: isImage,
      mimeType: mimeType,
      localBytes: localBytes,
      syncStatus: AttachmentSyncStatus.local,
    );
  }

  factory SaleFormAttachment.fromApi(Map<String, dynamic> json) {
    final mime = json['mime_type'] as String? ?? 'application/octet-stream';
    return SaleFormAttachment(
      id: json['id'] as String,
      remoteId: json['id'] as String,
      name: json['file_name'] as String? ?? 'attachment',
      path: json['file_url'] as String? ?? '',
      fileUrl: json['download_url'] as String? ?? json['file_url'] as String?,
      mimeType: mime,
      isImage: mime.startsWith('image/'),
      syncStatus: AttachmentSyncStatus.synced,
    );
  }

  final String id;
  final String name;
  final String path;
  final String? remoteId;
  final String? fileUrl;
  final String? mimeType;
  final bool isImage;
  final Uint8List? localBytes;
  final AttachmentSyncStatus syncStatus;
  final String? replacesRemoteId;

  String get displayName {
    if (name.isNotEmpty) return name;
    final segments = path.split(RegExp(r'[/\\]'));
    return segments.isNotEmpty ? segments.last : path;
  }

  bool get isPdf => mimeType == 'application/pdf';

  bool get canPreview =>
      isImage && (localBytes != null || (fileUrl != null && fileUrl!.isNotEmpty));

  SaleFormAttachment copyWith({
    String? name,
    String? path,
    String? remoteId,
    String? fileUrl,
    String? mimeType,
    bool? isImage,
    Uint8List? localBytes,
    AttachmentSyncStatus? syncStatus,
    String? replacesRemoteId,
  }) {
    return SaleFormAttachment(
      id: id,
      name: name ?? this.name,
      path: path ?? this.path,
      remoteId: remoteId ?? this.remoteId,
      fileUrl: fileUrl ?? this.fileUrl,
      mimeType: mimeType ?? this.mimeType,
      isImage: isImage ?? this.isImage,
      localBytes: localBytes ?? this.localBytes,
      syncStatus: syncStatus ?? this.syncStatus,
      replacesRemoteId: replacesRemoteId ?? this.replacesRemoteId,
    );
  }
}
