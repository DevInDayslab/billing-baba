import 'package:billing_baba/core/attachments/document_attachment_repository.dart';
import 'package:billing_baba/core/attachments/document_attachment_service.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final documentAttachmentServiceProvider =
    FutureProvider<DocumentAttachmentService>((ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return DocumentAttachmentService(DocumentAttachmentRepository(api.dio));
});
