import 'package:billing_baba/features/collaboration/presentation/providers/company_access_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/company_directory_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/company_session_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/invitations_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/members_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reloads collaboration data when the active company changes.
final collaborationScopeProvider = Provider<void>((ref) {
  ref.listen(companySessionProvider, (previous, next) {
    if (previous?.companyId == next?.companyId) return;
    ref.invalidate(membersProvider);
    ref.invalidate(invitationsProvider);
    ref.invalidate(companyAccessProvider);
    ref.invalidate(companyDirectoryProvider);
    ref.invalidate(collaborationCompaniesProvider);
  });
});
