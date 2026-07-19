import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_repository_provider.dart';
import 'package:billing_baba/features/collaboration/application/company_directory_service.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_list_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final companyDirectoryServiceProvider =
    FutureProvider<CompanyDirectoryService>((ref) async {
      final businessService = await ref.watch(businessServiceProvider.future);
      final collaborationRepository = ref.watch(
        collaborationRepositoryProvider,
      );
      return CompanyDirectoryService(
        businessService: businessService,
        collaborationRepository: collaborationRepository,
      );
    });

final companyDirectoryProvider = FutureProvider<List<CompanyListEntry>>((
  ref,
) async {
  final service = await ref.watch(companyDirectoryServiceProvider.future);
  return service.loadDirectory();
});

final collaborationCompaniesProvider = FutureProvider<List<CompanyListEntry>>((
  ref,
) async {
  final repository = ref.watch(collaborationRepositoryProvider);
  return repository.loadCompanies();
});
