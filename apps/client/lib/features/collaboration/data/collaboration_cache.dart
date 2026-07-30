import 'package:billing_baba/features/collaboration/domain/models/business_member.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_access.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_list_entry.dart';
import 'package:billing_baba/features/collaboration/domain/models/invitation.dart';

class CollaborationCompanyCache {
  CollaborationCompanyCache({
    this.invitations = const [],
    this.members = const [],
    this.companyAccess,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  List<Invitation> invitations;
  List<BusinessMember> members;
  CompanyAccess? companyAccess;
  DateTime updatedAt;

  void replaceInvitations(List<Invitation> value) {
    invitations = List<Invitation>.from(value);
    updatedAt = DateTime.now();
  }

  void replaceMembers(List<BusinessMember> value) {
    members = List<BusinessMember>.from(value);
    updatedAt = DateTime.now();
  }

  void replaceCompanyAccess(CompanyAccess value) {
    companyAccess = value;
    updatedAt = DateTime.now();
  }
}

class CollaborationDirectoryCache {
  CollaborationDirectoryCache({
    this.companies = const [],
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  List<CompanyListEntry> companies;
  DateTime updatedAt;

  void replaceCompanies(List<CompanyListEntry> value) {
    companies = List<CompanyListEntry>.from(value);
    updatedAt = DateTime.now();
  }
}

class CollaborationCache {
  final Map<String, CollaborationCompanyCache> _companies = {};
  CollaborationDirectoryCache directory = CollaborationDirectoryCache();

  CollaborationCompanyCache company(String companyId) {
    return _companies.putIfAbsent(companyId, CollaborationCompanyCache.new);
  }

  void clearCompany(String companyId) {
    _companies.remove(companyId);
  }

  void clearDirectory() {
    directory = CollaborationDirectoryCache();
  }
}
