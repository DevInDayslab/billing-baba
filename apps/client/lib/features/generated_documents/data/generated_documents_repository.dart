import 'dart:convert';
import 'dart:typed_data';

import 'package:billing_baba/features/generated_documents/data/generated_documents_remote_data_source.dart';
import 'package:billing_baba/features/generated_documents/models/generated_document_dto.dart';

class GeneratedDocumentsRepository {
  GeneratedDocumentsRepository(this._remote);

  final GeneratedDocumentsRemoteDataSource _remote;

  Future<GeneratedDocumentDto?> lookup({
    required String documentKind,
    required String sourceType,
    required String sourceId,
  }) => _remote.lookup(
    documentKind: documentKind,
    sourceType: sourceType,
    sourceId: sourceId,
  );

  Future<GeneratedDocumentDto> ensure({
    required String documentKind,
    required String sourceType,
    required String sourceId,
    Uint8List? bytes,
    String? fileName,
    bool forceRegenerate = false,
  }) => _remote.ensure(
    documentKind: documentKind,
    sourceType: sourceType,
    sourceId: sourceId,
    contentBase64: bytes == null ? null : base64Encode(bytes),
    fileName: fileName,
    forceRegenerate: forceRegenerate,
  );

  Future<String> resolveDownloadUrl(GeneratedDocumentDto document) async {
    if (document.downloadUrl != null && document.downloadUrl!.isNotEmpty) {
      return document.downloadUrl!;
    }
    final result = await _remote.getDownloadUrl(document.id);
    return result.downloadUrl;
  }

  Future<Uint8List> download(GeneratedDocumentDto document) async {
    final url = await resolveDownloadUrl(document);
    return _remote.downloadBytes(url);
  }
}
