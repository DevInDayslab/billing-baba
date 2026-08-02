import 'package:billing_baba/features/parties/data/gstin_repository.dart';
import 'package:billing_baba/features/parties/models/gstin_verification_response.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gstin_verification_service.g.dart';

class GstinVerificationService {
  GstinVerificationService(this._repository);

  final GstinRepository _repository;

  Future<GstinVerificationResponse> verify(String gstin) {
    return _repository.verify(gstin);
  }
}

@Riverpod(keepAlive: true)
Future<GstinVerificationService> gstinVerificationService(Ref ref) async {
  final repository = await ref.watch(gstinRepositoryProvider.future);
  return GstinVerificationService(repository);
}
