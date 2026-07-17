import 'package:billing_baba/features/collaboration/application/collaboration_repository_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/company_access_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/devices_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/invitations_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/members_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/sync_status_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'collaboration_refresh_provider.g.dart';

@Riverpod(keepAlive: true)
class CollaborationRefresh extends _$CollaborationRefresh {
  @override
  bool build() => false;

  Future<void> refreshAll({bool showLoading = false}) async {
    state = true;
    try {
      final service = ref.read(collaborationServiceProvider);
      await service.refresh();
      await Future.wait([
        ref.read(membersProvider.notifier).reload(showLoading: showLoading),
        ref.read(invitationsProvider.notifier).reload(showLoading: showLoading),
        ref.read(devicesProvider.notifier).reload(showLoading: showLoading),
        ref.read(syncStatusProvider.notifier).reload(showLoading: showLoading),
      ]);
      ref.invalidate(companyAccessProvider);
    } finally {
      state = false;
    }
  }
}
