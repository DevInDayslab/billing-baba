import 'package:billing_baba/core/network/business_selection_retry_guard.dart';
import 'package:billing_baba/core/network/network_exception_classifier.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_profile_offline_resolver.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/models/business_profile_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loads business profile for the mobile edit screen with offline fallbacks.
final mobileBusinessProfileLoaderProvider =
    FutureProvider.autoDispose<BusinessProfileModel>((ref) async {
      final cachedProfile = ref.read(businessProfileProvider).asData?.value;
      if (cachedProfile != null) {
        return cachedProfile;
      }

      final service = await ref.read(businessServiceProvider.future);
      final businessId =
          ref.read(sidebarBusinessProvider).id ??
          await service.resolveActiveBusinessId();

      final skipApi =
          businessId != null && BusinessSelectionRetryGuard.isBlocked(businessId);

      if (!skipApi) {
        final auth = ref.read(authProvider);
        if (authHasBusinessScope(auth)) {
          try {
            final profile = await service.fetchBusinessProfile();
            ref.read(businessProfileProvider.notifier).replaceWith(profile);
            return profile;
          } on BusinessServerUnavailable {
            // Fall through to offline fallbacks.
          } on Object catch (error) {
            if (!NetworkExceptionClassifier.isConnectivityError(error)) {
              rethrow;
            }
          }
        }
      }

      final offlineProfile = await resolveOfflineBusinessProfile(
        ref: ref,
        service: service,
        businessId: businessId,
      );
      if (offlineProfile != null) {
        ref.read(businessProfileProvider.notifier).replaceWith(offlineProfile);
        return offlineProfile;
      }

      throw const BusinessProfileScopeRequired();
    });
