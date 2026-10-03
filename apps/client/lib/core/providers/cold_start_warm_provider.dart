import 'dart:async';

import 'package:billing_baba/core/providers/business_scope_invalidation.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/collaboration/application/company_session_provider.dart';
import 'package:billing_baba/shared/utils/jwt_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Runs cache-first [warmBusinessScopedProvidersCritical] once per business
/// after authenticated cold start (already logged in → Home), so dashboard /
/// profile / settings do not wait on first navigation.
final coldStartWarmProvider = Provider<void>((ref) {
  var warmingBusinessId = '';

  Future<void> tryWarm() async {
    if (!ref.mounted) return;

    final auth = ref.read(authProvider);
    if (auth.status != AuthStatus.authenticated) return;
    if (!authHasBusinessScope(auth)) return;

    // Avoid racing the company-open overlay warm path.
    if (ref.read(businessSessionLoadingProvider) != null) return;

    final sessionBusinessId = ref.read(companySessionProvider)?.companyId;
    final jwtBusinessId = JwtUtils.businessId(auth.session?.accessToken);
    var businessId = sessionBusinessId;
    if (businessId == null || businessId.isEmpty) {
      businessId = jwtBusinessId;
    }
    if (businessId == null || businessId.isEmpty) {
      try {
        final service = await ref.read(businessServiceProvider.future);
        if (!ref.mounted) return;
        businessId = await service.resolveActiveBusinessId();
      } on Object {
        return;
      }
    }
    if (!ref.mounted) return;
    if (businessId == null || businessId.isEmpty) return;
    if (warmingBusinessId == businessId) return;

    warmingBusinessId = businessId;
    try {
      await warmBusinessScopedProvidersCritical(ref, businessId: businessId);
      if (!ref.mounted) return;
      // Background network + list prefetch (same as post company-open).
      unawaited(
        warmBusinessScopedProvidersDeferred(ref, businessId: businessId),
      );
    } on Object {
      // Allow a later retry if critical warm fails (e.g. storage not ready).
      warmingBusinessId = '';
    }
  }

  void scheduleWarm() => unawaited(tryWarm());

  ref
    ..listen(authProvider, (_, _) => scheduleWarm())
    ..listen(companySessionProvider, (_, _) => scheduleWarm())
    ..listen(businessSessionLoadingProvider, (previous, next) {
      // When company-open overlay clears, warm again if cold start skipped.
      if (previous != null && next == null) {
        scheduleWarm();
      }
    });

  unawaited(Future.microtask(scheduleWarm));
});
