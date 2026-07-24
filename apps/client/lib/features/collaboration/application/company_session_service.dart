import 'dart:async';

import 'package:billing_baba/core/providers/business_scope_invalidation.dart';
import 'package:billing_baba/features/auth/providers/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/utils/business_open_debug_log.dart';
import 'package:billing_baba/features/collaboration/data/collaboration_repository.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_list_entry.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_relationship.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_session.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/company_directory_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/company_session_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/permission_service_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/sync_share_refresh_provider.dart';
import 'package:billing_baba/features/pos/providers/pos_cart_provider.dart';
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

    final ownedApiCompany = entry.relationship.isOwner &&
        entry.source == CompanyListSource.apiOwned;

    if (ownedApiCompany) {
      _ref.read(businessSessionLoadingProvider.notifier).start(entry.id);
      try {
        await _scopeOwnedApiCompany(entry);
        session = CompanySession.owner(
          entry: entry,
          userId: userId,
          userName: userName,
          userPhone: userPhone,
        );
        _applySession(session, skipScopedInvalidation: true);
        unawaited(_warmOwnedApiCompanyInBackground(entry.id));
      } on Object {
        _ref.read(businessSessionLoadingProvider.notifier).clear();
        rethrow;
      }
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
      _applySession(session);
    }

    return session;
  }

  Future<CompanyListEntry> acceptInvite(String invitationId) async {
    final entry = await _collaborationRepository.acceptCompanyInvitation(
      invitationId,
    );
    await _ref.read(syncShareRefreshProvider.notifier).refreshAfterMutation();
    return entry;
  }

  Future<void> rejectInvite(String invitationId) async {
    await _collaborationRepository.rejectCompanyInvitation(invitationId);
    await _ref.read(syncShareRefreshProvider.notifier).refreshAfterMutation();
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
    await _ref.read(syncShareRefreshProvider.notifier).refreshAfterMutation();
  }

  Future<void> _scopeOwnedApiCompany(CompanyListEntry entry) async {
    final businessId = entry.id;
    BusinessOpenDebugLog.step('scopeOwnedApiCompany', 'start id=$businessId');

    final previousId = await _businessService.readActiveBusinessId();
    final isSwitch =
        previousId != null && previousId.isNotEmpty && previousId != businessId;
    BusinessOpenDebugLog.step(
      'scopeOwnedApiCompany',
      'previousId=${previousId ?? '(none)'} isSwitch=$isSwitch',
    );

    if (isSwitch) {
      await _businessService.clearCachedBusinessProfile();
      _ref.invalidate(posCartProvider);
    }

    await _businessService.rememberLastOpened(businessId);
    await _ref.read(authProvider.notifier).selectBusiness(businessId);

    final auth = _ref.read(authProvider);
    if (auth.status != AuthStatus.authenticated) {
      throw const BusinessSelectionFailed(
        'Could not scope session to company. Please try again.',
      );
    }

    if (!await _businessService.isJwtScopedToBusiness(businessId)) {
      throw const BusinessSelectionFailed(
        'Could not scope session to company. Please try again.',
      );
    }

    invalidateAllBusinessScopedProviders(
      _ref,
      includeBusinessService: false,
    );
    seedBusinessProfilePreview(_ref, entry: entry);
    BusinessOpenDebugLog.step('scopeOwnedApiCompany', 'complete');
  }

  Future<void> _warmOwnedApiCompanyInBackground(String businessId) async {
    try {
      await warmBusinessScopedProviders(_ref, businessId: businessId);
    } on Object catch (error) {
      BusinessOpenDebugLog.step('warm', 'background failed: $error');
    } finally {
      if (_ref.mounted) {
        _ref.read(businessSessionLoadingProvider.notifier).clear();
      }
    }
  }

  void _applySession(
    CompanySession session, {
    bool skipScopedInvalidation = false,
  }) {
    _ref.read(companySessionProvider.notifier).setSession(session);
    _ref.invalidate(permissionServiceProvider);
    if (skipScopedInvalidation) return;
    _ref.invalidate(companyDirectoryProvider);
    invalidateAllBusinessScopedProviders(_ref, includeBusinessList: true);
  }
}
