import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/utils/switch_company_debug_log.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_repository_provider.dart';
import 'package:billing_baba/features/collaboration/application/company_directory_service.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_list_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final companyDirectoryServiceProvider =
    FutureProvider<CompanyDirectoryService>(
  (ref) async {
    // Directory is user-scoped. Rebuild only when the signed-in user or
    // BusinessService changes — not when companySession / businessProfile
    // churn recreates collaborationRepository during Switch Company.
    final userId = ref.watch(authProvider.select((a) => a.session?.user.id));
    SwitchCompanyDebugLog.invalidate(
      'companyDirectoryService rebuild (userId=$userId)',
    );
    final businessService = await ref.watch(businessServiceProvider.future);
    final collaborationRepository = ref.read(
      collaborationRepositoryProvider,
    );
    return CompanyDirectoryService(
      businessService: businessService,
      collaborationRepository: collaborationRepository,
    );
  },
  // Offline / connection failures must surface once; manual Retry only.
  retry: (_, _) => null,
);

final companyDirectoryProvider = FutureProvider<List<CompanyListEntry>>(
  (ref) async {
    SwitchCompanyDebugLog.api('companyDirectoryProvider loadDirectory start');
    final service = await ref.watch(companyDirectoryServiceProvider.future);
    final entries = await service.loadDirectory();
    SwitchCompanyDebugLog.api(
      'companyDirectoryProvider loadDirectory done (${entries.length})',
    );
    return entries;
  },
  retry: (_, _) => null,
);

final collaborationCompaniesProvider = FutureProvider<List<CompanyListEntry>>((
  ref,
) async {
  final repository = ref.watch(collaborationRepositoryProvider);
  return repository.loadCompanies();
});
