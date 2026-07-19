import 'package:billing_baba/core/providers/business_scope_invalidation.dart';
import 'package:billing_baba/features/auth/providers/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/collaboration/data/collaboration_repository.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_list_entry.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_relationship.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_session.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/company_directory_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/company_session_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/permission_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompanySessionOpenBlocked implements Exception {
  const CompanySessionOpenBlocked(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Opens, switches, and leaves companies; coordinates session + invalidation.
class CompanySessionService {
  CompanySessionService({
    required this._ref,
    required this._businessService,
    required this._collaborationRepository,
  });

  final Ref _ref;
  final BusinessService _businessService;
  final CollaborationRepository _collaborationRepository;

  Future<CompanySession> openCompany(CompanyListEntry entry) async {
    if (entry.relationship.isPending) {
      throw const CompanySessionOpenBlocked(
        'Accept the invitation before opening this company.',
      );
    }
    if (entry.relationship.isExpired) {
      throw const CompanySessionOpenBlocked('This invitation has expired.');
    }

    final auth = _ref.read(authProvider);
    final user = auth.session?.user;
    final userId = user?.id ?? 'local-user';
    final userName = user?.name ?? 'User';
    final userPhone = user?.phone ?? '';

    CompanySession session;

    if (entry.relationship.isOwner &&
        entry.source == CompanyListSource.apiOwned) {
      await _ref.read(businessListProvider.notifier).openBusiness(entry.id);
      session = CompanySession.owner(
        entry: entry,
        userId: userId,
        userName: userName,
        userPhone: userPhone,
      );
    } else {
      session = await _collaborationRepository.switchCompany(
        companyId: entry.id,
        userId: userId,
        userName: userName,
      );
      invalidateAllBusinessScopedProviders(
        _ref,
        includeBusinessList: true,
      );
    }

    _applySession(session);
    return session;
  }

  Future<CompanyListEntry> acceptInvite(String invitationId) async {
    final entry = await _collaborationRepository.acceptCompanyInvitation(
      invitationId,
    );
    _ref.invalidate(companyDirectoryProvider);
    return entry;
  }

  Future<void> rejectInvite(String invitationId) async {
    await _collaborationRepository.rejectCompanyInvitation(invitationId);
    _ref.invalidate(companyDirectoryProvider);
  }

  Future<void> leaveCompany(CompanyListEntry entry) async {
    if (entry.relationship.isOwner &&
        entry.source == CompanyListSource.apiOwned) {
      // Owner leave is handled elsewhere (delete business flow).
      return;
    }

    await _collaborationRepository.leaveCompany(entry.id);
    final current = _ref.read(companySessionProvider);
    if (current?.companyId == entry.id) {
      _ref.read(companySessionProvider.notifier).clear();
      invalidateAllBusinessScopedProviders(
        _ref,
        includeBusinessList: true,
      );
    }
    _ref.invalidate(companyDirectoryProvider);
  }

  void _applySession(CompanySession session) {
    _ref.read(companySessionProvider.notifier).setSession(session);
    _ref.invalidate(permissionServiceProvider);
    _ref.invalidate(companyDirectoryProvider);
    invalidateAllBusinessScopedProviders(_ref, includeBusinessList: true);
  }
}
