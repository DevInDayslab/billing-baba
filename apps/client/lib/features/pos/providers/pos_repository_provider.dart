import 'package:billing_baba/features/pos/repositories/inventory_pos_repository.dart';
import 'package:billing_baba/features/pos/repositories/pos_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pos_repository_provider.g.dart';

@riverpod
PosRepository posRepository(Ref ref) {
  return InventoryPosRepository(ref);
  // When POS sale API is ready: compose InventoryPosRepository with ApiPosRepository.
}
