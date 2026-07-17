import 'package:billing_baba/features/collaboration/application/collaboration_repository_provider.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_service_types.dart';
import 'package:billing_baba/features/collaboration/domain/models/business_member.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/collaboration_init_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/company_access_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/invitations_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'members_provider.g.dart';

@Riverpod(keepAlive: true)
class Members extends _$Members {
  @override
  Future<List<BusinessMember>> build() async {
    ref.watch(collaborationInitProvider);
    final service = ref.watch(collaborationServiceProvider);
    return service.fetchMembers();
  }

  Future<void> reload({bool showLoading = true}) async {
    if (showLoading) {
      state = const AsyncLoading();
    }
    state = await AsyncValue.guard(() async {
      final service = ref.read(collaborationServiceProvider);
      return service.fetchMembers();
    });
  }

  Future<BusinessMember> updateMember(
    String id,
    UpdateMemberInput input,
  ) async {
    final service = ref.read(collaborationServiceProvider);
    final member = await service.updateMember(id, input);
    await reload(showLoading: false);
    return member;
  }

  Future<void> removeMember(String id) async {
    final service = ref.read(collaborationServiceProvider);
    await service.removeMember(id);
    await reload(showLoading: false);
    await ref.read(invitationsProvider.notifier).reload(showLoading: false);
    ref.invalidate(companyAccessProvider);
  }
}
