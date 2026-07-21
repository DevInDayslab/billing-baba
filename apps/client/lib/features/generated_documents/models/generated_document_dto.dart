class GeneratedDocumentDto {
  const GeneratedDocumentDto({
    required this.id,
    required this.documentKind,
    required this.sourceType,
    required this.sourceId,
    required this.fileName,
    required this.mimeType,
    required this.cached,
    this.downloadUrl,
    this.publicUrl,
    this.sourceVersion,
    this.generatedAt,
  });

  factory GeneratedDocumentDto.fromJson(Map<String, dynamic> json) {
    return GeneratedDocumentDto(
      id: json['id'] as String,
      documentKind: json['document_kind'] as String,
      sourceType: json['source_type'] as String,
      sourceId: json['source_id'] as String,
      fileName: json['file_name'] as String? ?? 'document.pdf',
      mimeType: json['mime_type'] as String? ?? 'application/pdf',
      cached: json['cached'] as bool? ?? false,
      downloadUrl: json['download_url'] as String?,
      publicUrl: json['public_url'] as String?,
      sourceVersion: _stringOrNull(json['source_version']),
      generatedAt: json['generated_at'] as String?,
    );
  }

  static String? _stringOrNull(Object? value) {
    if (value == null) return null;
    return value.toString();
  }

  final String id;
  final String documentKind;
  final String sourceType;
  final String sourceId;
  final String fileName;
  final String mimeType;
  final bool cached;
  final String? downloadUrl;
  final String? publicUrl;
  final String? sourceVersion;
  final String? generatedAt;
}

class GeneratedDocumentDownloadUrlDto {
  const GeneratedDocumentDownloadUrlDto({
    required this.downloadUrl,
    this.expiresAt,
  });

  factory GeneratedDocumentDownloadUrlDto.fromJson(Map<String, dynamic> json) {
    return GeneratedDocumentDownloadUrlDto(
      downloadUrl: json['download_url'] as String? ?? '',
      expiresAt: json['expires_at'] as String?,
    );
  }

  final String downloadUrl;
  final String? expiresAt;
}
