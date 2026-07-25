import 'package:billing_baba/features/collaboration/application/collaboration_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'collaboration_init_provider.g.dart';

@Riverpod(keepAlive: true)
class CollaborationInit extends _$CollaborationInit {
  @override
  Future<void> build() async {
    final service = ref.watch(collaborationServiceProvider);
    await service.initialize();
  }
}
