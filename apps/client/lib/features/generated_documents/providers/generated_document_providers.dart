import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/generated_documents/application/generated_document_service.dart';
import 'package:billing_baba/features/generated_documents/data/generated_documents_remote_data_source.dart';
import 'package:billing_baba/features/generated_documents/data/generated_documents_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final generatedDocumentServiceProvider =
    FutureProvider<GeneratedDocumentService>((ref) async {
  final api = await ref.watch(apiClientProvider.future);
  final remote = GeneratedDocumentsRemoteDataSource(api.dio);
  return GeneratedDocumentService(GeneratedDocumentsRepository(remote));
});
