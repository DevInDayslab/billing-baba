import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_service.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_service_types.dart';
import 'package:billing_baba/features/collaboration/data/backend_collaboration_repository.dart';
import 'package:billing_baba/features/collaboration/data/collaboration_api.dart';
import 'package:billing_baba/features/collaboration/data/collaboration_cache.dart';
import 'package:billing_baba/features/collaboration/data/collaboration_repository.dart';
import 'package:billing_baba/features/collaboration/data/fake_collaboration_repository.dart';
import 'package:billing_baba/features/collaboration/application/company_session_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'collaboration_repository_provider.g.dart';

bool get useFakeCollaborationRepository {
  if (!kDebugMode) return false;
  return dotenv.env['USE_FAKE_COLLABORATION']?.toLowerCase() == 'true';
}

String _defaultDeviceName() {
  if (kIsWeb) return 'Web Browser';
  final platform = AppPlatform.current;
  if (platform.isMacOS) return 'MacBook Pro';
  if (platform.isWindows) return 'Windows Desktop';
  if (platform.isAndroid) return 'Android Device';
  if (platform.isIOS) return 'iPhone';
  return 'Desktop';
}

@Riverpod(keepAlive: true)
CollaborationCache collaborationCache(Ref ref) => CollaborationCache();

@Riverpod(keepAlive: true)
CollaborationRepository collaborationRepository(Ref ref) {
  final auth = ref.watch(authProvider);
  final session = ref.watch(companySessionProvider);
  final apiAsync = ref.watch(apiClientProvider);
  final businessProfile = ref.watch(businessProfileProvider).value;
  final cache = ref.watch(collaborationCacheProvider);

  final user = auth.session?.user;
  final currentPhone = user?.phone ?? '';
  final businessId =
      session?.companyId ??
      (auth.session?.businesses.isNotEmpty == true
          ? auth.session!.businesses.first.id
          : null) ??
      businessProfile?.id ??
      'local-default';
  final businessName =
      session?.companyName ??
      businessProfile?.name ??
      (auth.session?.businesses.isNotEmpty == true
          ? auth.session!.businesses.first.name
          : null) ??
      'Business';

  final sessionContext = CollaborationSessionContext(
    currentUserPhone: currentPhone,
    ownerPhone: session?.ownerPhone ?? currentPhone,
    currentDeviceName: _defaultDeviceName(),
  );

  if (useFakeCollaborationRepository) {
    return FakeCollaborationRepository(
      businessId: businessId,
      businessName: businessName,
      sessionContext: sessionContext,
    );
  }

  final dio = apiAsync.maybeWhen(
    data: (client) => client.dio,
    orElse: () => null,
  );

  if (dio == null) {
    return FakeCollaborationRepository(
      businessId: businessId,
      businessName: businessName,
      sessionContext: sessionContext,
    );
  }

  return BackendCollaborationRepository(
    api: CollaborationApi(dio),
    companyId: businessId,
    companyName: businessName,
    sessionContext: sessionContext,
    cache: cache,
  );
}

@Riverpod(keepAlive: true)
CollaborationService collaborationService(Ref ref) {
  final repository = ref.watch(collaborationRepositoryProvider);
  return CollaborationService(repository);
}
