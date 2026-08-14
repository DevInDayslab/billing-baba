import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_repository_provider.dart';
import 'package:billing_baba/features/collaboration/application/company_session_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final companySessionServiceProvider = FutureProvider<CompanySessionService>((
  ref,
) async {
  final businessService = await ref.watch(businessServiceProvider.future);
  // Prefer read over watch: collaborationRepository rebuilds on every auth /
  // companySession change, which disposed this provider mid-openCompany and
  // aborted warm-up with a disposed Ref.
  final collaborationRepository = ref.read(collaborationRepositoryProvider);
  return CompanySessionService(
    ref: ref,
    businessService: businessService,
    collaborationRepository: collaborationRepository,
  );
});
