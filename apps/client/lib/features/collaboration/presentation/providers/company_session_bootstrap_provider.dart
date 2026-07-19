import 'package:billing_baba/features/auth/providers/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/models/business_model.dart'
    as business;
import 'package:billing_baba/features/collaboration/domain/models/company_list_entry.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_session.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_relationship.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/company_session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Seeds an owner [CompanySession] when the user is already scoped to a business.
final companySessionBootstrapProvider = Provider<void>((ref) {
  final session = ref.watch(companySessionProvider);
  if (session != null) return;

  final auth = ref.watch(authProvider);
  if (auth.status != AuthStatus.authenticated) return;
  if (!authHasBusinessScope(auth)) return;

  final profile = ref.watch(businessProfileProvider).value;
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
      ),
      userId: user.id,
      userName: user.name ?? 'User',
      userPhone: user.phone ?? '',
    ),
  );
});
