import 'package:billing_baba/features/pos/repositories/mock_pos_repository.dart';
import 'package:billing_baba/features/pos/repositories/pos_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pos_repository_provider.g.dart';

@riverpod
PosRepository posRepository(Ref ref) {
  return MockPosRepository();
  // When API ready: return ApiPosRepository(baseUrl: AppConfig.apiBaseUrl, businessId: '...');
}
