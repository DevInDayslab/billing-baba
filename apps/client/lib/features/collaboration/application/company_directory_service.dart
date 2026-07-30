import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/collaboration/data/collaboration_repository.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_list_entry.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_relationship.dart';

/// Merges API-owned businesses with fake collaboration companies.
class CompanyDirectoryService {
  CompanyDirectoryService({
    required this._businessService,
    required this._collaborationRepository,
  });

  final BusinessService _businessService;
  final CollaborationRepository _collaborationRepository;

  Future<List<CompanyListEntry>> loadDirectory({
    bool forceRefresh = false,
  }) async {
    final owned = await _businessService.fetchBusinesses(
      forceRefresh: forceRefresh,
    );
    final ownedEntries = owned
        .map(CompanyListEntry.fromBusinessModel)
        .map(
          (entry) => entry.copyWith(
            relationship: CompanyRelationship.owner,
          ),
        )
        .toList();

    try {
      final shared = await _collaborationRepository.loadCompanies();
      return [...ownedEntries, ...shared];
    } on Object {
      // Keep owned companies visible when collaboration APIs are unavailable.
      return ownedEntries;
    }
  }

  List<CompanyListEntry> ownedCompanies(List<CompanyListEntry> all) {
    return all.where((e) => e.relationship.isOwner).toList();
  }

  List<CompanyListEntry> sharedCompanies(List<CompanyListEntry> all) {
    return all.where((e) => e.isSharedTab).toList();
  }
}
