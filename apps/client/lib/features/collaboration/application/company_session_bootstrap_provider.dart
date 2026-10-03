import 'dart:async';

import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/auth/models/business_summary.dart';
import 'package:billing_baba/features/auth/services/auth_service.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/models/business_model.dart'
    as business;
import 'package:billing_baba/features/collaboration/application/company_session_provider.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_list_entry.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_relationship.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_session.dart';
import 'package:billing_baba/shared/utils/jwt_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Seeds an owner [CompanySession] when the user is already scoped to a business.
///
/// Updates are deferred via [ref.listen] and [Future.microtask] so we never
/// modify [companySessionProvider] during this provider's build phase.
///
/// Prefer seeding from auth session businesses immediately (before
/// [businessProfileProvider] finishes) so the desktop sidebar is not empty
/// on cold start.
final companySessionBootstrapProvider = Provider<void>((ref) {
  void setOwnerSession({
    required CompanyListEntry entry,
    required String userId,
    required String userName,
    required String userPhone,
  }) {
    ref
        .read(companySessionProvider.notifier)
        .setSession(
          CompanySession.owner(
            entry: entry,
            userId: userId,
            userName: userName,
            userPhone: userPhone,
          ),
        );
  }

  CompanyListEntry entryFromSummary(BusinessSummary summary) {
    return CompanyListEntry(
      id: summary.id,
      name: summary.name,
      relationship: CompanyRelationship.owner,
      syncStatus: business.SyncStatus.on,
      source: CompanyListSource.apiOwned,
      gstin: summary.gstin,
    );
  }

  BusinessSummary? resolveAuthBusinessSummary() {
    final session = ref.read(authProvider).session;
    if (session == null || session.businesses.isEmpty) return null;

    final jwtBusinessId = JwtUtils.businessId(session.accessToken);
    if (jwtBusinessId != null && jwtBusinessId.isNotEmpty) {
      for (final b in session.businesses) {
        if (b.id == jwtBusinessId) return b;
      }
    }

    if (session.businesses.length == 1) {
      return session.businesses.first;
    }

    return session.businesses.first;
  }

  void tryBootstrap() {
    if (!ref.mounted) return;

    final auth = ref.read(authProvider);
    if (auth.status != AuthStatus.authenticated) return;
    if (!authHasBusinessScope(auth)) return;

    final existing = ref.read(companySessionProvider);
    final profile = ref.read(businessProfileProvider).value;
    final user = auth.session!.user;

    // Upgrade a provisional auth-seeded session once the full profile arrives.
    if (existing != null) {
      if (profile != null &&
          existing.companyId == profile.id &&
          existing.companyName != profile.name) {
        setOwnerSession(
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
        );
      }
      return;
    }

    if (profile != null) {
      setOwnerSession(
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
      );
      return;
    }

    // Cold start: seed from auth businesses before profile fetch completes.
    final summary = resolveAuthBusinessSummary();
    if (summary != null) {
      final isOfflineDev =
          AuthService.isOfflineDevSession(auth.session!) &&
          auth.session!.businesses.isNotEmpty;
      setOwnerSession(
        entry: entryFromSummary(summary),
        userId: user.id,
        userName: user.name ?? (isOfflineDev ? 'Developer' : 'User'),
        userPhone: user.phone,
      );
      return;
    }

    // Async fallback: resolve active business id from storage / cache.
    unawaited(() async {
      if (!ref.mounted) return;
      if (ref.read(companySessionProvider) != null) return;

      try {
        final service = await ref.read(businessServiceProvider.future);
        if (!ref.mounted) return;
        final businessId = await service.resolveActiveBusinessId();
        if (!ref.mounted || businessId == null || businessId.isEmpty) return;
        if (ref.read(companySessionProvider) != null) return;

        final cached = await service.readCachedBusinessProfile();
        if (!ref.mounted) return;
        if (ref.read(companySessionProvider) != null) return;

        final authNow = ref.read(authProvider);
        final userNow = authNow.session?.user;
        if (userNow == null) return;

        if (cached != null && cached.id == businessId) {
          setOwnerSession(
            entry: CompanyListEntry(
              id: cached.id,
              name: cached.name,
              relationship: CompanyRelationship.owner,
              syncStatus: business.SyncStatus.on,
              source: CompanyListSource.apiOwned,
              gstin: cached.gstin,
              phone: cached.phone,
              email: cached.email,
              address: cached.address,
              logoUrl: cached.logoUrl,
            ),
            userId: userNow.id,
            userName: userNow.name ?? 'User',
            userPhone: userNow.phone,
          );
          return;
        }

        for (final b
            in authNow.session?.businesses ?? const <BusinessSummary>[]) {
          if (b.id == businessId) {
            setOwnerSession(
              entry: entryFromSummary(b),
              userId: userNow.id,
              userName: userNow.name ?? 'User',
              userPhone: userNow.phone,
            );
            return;
          }
        }
      } on Object {
        // Sidebar nav fallback covers the brief gap; ignore bootstrap errors.
      }
    }());
  }

  ref
    ..listen(authProvider, (_, _) => tryBootstrap())
    ..listen(businessProfileProvider, (_, _) => tryBootstrap());

  unawaited(Future.microtask(tryBootstrap));
});
