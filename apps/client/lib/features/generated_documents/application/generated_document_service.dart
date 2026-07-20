import 'dart:typed_data';

import 'package:billing_baba/features/generated_documents/application/generated_document_query.dart';
import 'package:billing_baba/features/generated_documents/data/generated_documents_repository.dart';
import 'package:billing_baba/features/generated_documents/models/generated_document_dto.dart';
import 'package:billing_baba/features/print/models/print_request.dart';

class GeneratedDocumentService {
  GeneratedDocumentService(this._repository);

  final GeneratedDocumentsRepository _repository;

  Future<GeneratedDocumentDto?> lookup({
    required String documentKind,
    required String sourceType,
    required String sourceId,
  }) =>
      _repository.lookup(
        documentKind: documentKind,
        sourceType: sourceType,
        sourceId: sourceId,
      );

  Future<GeneratedDocumentDto> refresh({
    required String documentKind,
    required String sourceType,
    required String sourceId,
    Uint8List? clientBytes,
    String? fileName,
  }) =>
      _repository.ensure(
        documentKind: documentKind,
        sourceType: sourceType,
        sourceId: sourceId,
        bytes: clientBytes,
        fileName: fileName,
        forceRegenerate: clientBytes == null,
      );

  Future<Uint8List> download({
    required String documentKind,
    required String sourceType,
    required String sourceId,
    bool refreshIfMissing = true,
  }) async {
    var document = await _repository.lookup(
      documentKind: documentKind,
      sourceType: sourceType,
      sourceId: sourceId,
    );

    if (document == null && refreshIfMissing) {
      document = await refresh(
        documentKind: documentKind,
        sourceType: sourceType,
        sourceId: sourceId,
      );
    }

    if (document == null) {
      throw StateError('Generated document is not available');
    }

    return _repository.download(document);
  }

  Future<Uint8List> downloadForPrintRequest(
    PrintRequest request, {
    bool refreshIfMissing = true,
  }) async {
    final query = generatedDocumentQueryForPrintRequest(request);
    if (query == null) {
      throw UnsupportedError(
        'Cloud download is not supported for ${request.kind.name}',
      );
    }

    return download(
      documentKind: query.documentKind,
      sourceType: query.sourceType,
      sourceId: query.sourceId,
      refreshIfMissing: refreshIfMissing,
    );
  }
}
