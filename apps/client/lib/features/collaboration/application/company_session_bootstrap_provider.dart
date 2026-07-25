import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/models/business_model.dart'
    as business;
import 'package:billing_baba/features/collaboration/domain/models/company_list_entry.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_relationship.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_session.dart';
import 'package:billing_baba/features/collaboration/application/company_session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Seeds an owner [CompanySession] when the user is already scoped to a business.
///
/// Updates are deferred via [ref.listen] and [Future.microtask] so we never
/// modify [companySessionProvider] during this provider's build phase.
final companySessionBootstrapProvider = Provider<void>((ref) {
  void tryBootstrap() {
    if (!ref.mounted) return;
    if (ref.read(companySessionProvider) != null) return;

    final auth = ref.read(authProvider);
    if (auth.status != AuthStatus.authenticated) return;
    if (!authHasBusinessScope(auth)) return;

    final profile = ref.read(businessProfileProvider).value;
    if (profile == null) return;

    final user = auth.session!.user;
    ref.read(companySessionProvider.notifier).setSession(
      CompanySession.owner(
        entry: CompanyListEntry(
          id: profile.id,
          name: profile.name,
          relationship: CompanyRelationship.owner,
          syncStatus: business.SyncStatus.on,
          source: CompanyListSource.apiOwned,
          gstin: profile.gstin,
          phone: profile.phone,
          email: profile.email,
          address: profile.address,
          logoUrl: profile.logoUrl,
        ),
        userId: user.id,
        userName: user.name ?? 'User',
        userPhone: user.phone,
      ),
    );
  }

  ref.listen(authProvider, (_, _) => tryBootstrap());
  ref.listen(businessProfileProvider, (_, _) => tryBootstrap());

  Future.microtask(tryBootstrap);
});
