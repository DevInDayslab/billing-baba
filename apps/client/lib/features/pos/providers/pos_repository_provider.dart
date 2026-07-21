import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/pos/application/pos_sale_service.dart';
import 'package:billing_baba/features/pos/repositories/api_pos_repository.dart';
import 'package:billing_baba/features/pos/repositories/pos_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pos_repository_provider.g.dart';

@riverpod
Future<PosRepository> posRepository(Ref ref) async {
  final posSaleService = await ref.watch(posSaleServiceProvider.future);
  return ApiPosRepository(posSaleService: posSaleService);
}

@riverpod
String? activePosBusinessId(Ref ref) {
  return ref.watch(currentBusinessProvider)?.id;
}
