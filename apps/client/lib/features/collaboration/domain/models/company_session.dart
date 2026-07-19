import 'package:billing_baba/features/business/models/business_model.dart'
    as business;
import 'package:billing_baba/features/collaboration/domain/models/company_list_entry.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_relationship.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_preset.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:billing_baba/features/collaboration/domain/owner_permission_preset.dart';

/// Active company context after opening a business from the list.
class CompanySession {
  const CompanySession({
    required this.companyId,
    required this.companyName,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserPhone,
    required this.relationship,
    required this.permissionPreset,
    required this.syncStatus,
    required this.source,
    this.role,
    this.ownerName,
    this.ownerPhone,
  });

  factory CompanySession.owner({
    required CompanyListEntry entry,
    required String userId,
    required String userName,
    required String userPhone,
  }) {
    return CompanySession(
      companyId: entry.id,
      companyName: entry.name,
      currentUserId: userId,
      currentUserName: userName,
      currentUserPhone: userPhone,
      relationship: CompanyRelationship.owner,
      permissionPreset: OwnerPermissionPreset.preset,
      syncStatus: entry.syncStatus,
      ownerName: userName,
      ownerPhone: userPhone,
      source: entry.source,
    );
  }

  factory CompanySession.shared({
    required CompanyListEntry entry,
    required String userId,
    required String userName,
    required String userPhone,
    required PermissionPreset preset,
  }) {
    return CompanySession(
      companyId: entry.id,
      companyName: entry.name,
      currentUserId: userId,
      currentUserName: userName,
      currentUserPhone: userPhone,
      relationship: entry.relationship == CompanyRelationship.secondaryAdmin
          ? CompanyRelationship.secondaryAdmin
          : CompanyRelationship.member,
      role: entry.role,
      permissionPreset: preset,
      syncStatus: entry.syncStatus,
      ownerName: entry.ownerName,
      ownerPhone: entry.ownerPhone,
      source: entry.source,
    );
  }

  final String companyId;
  final String companyName;
  final String currentUserId;
  final String currentUserName;
  final String currentUserPhone;
  final CompanyRelationship relationship;
  final Role? role;
  final PermissionPreset permissionPreset;
  final business.SyncStatus syncStatus;
  final String? ownerName;
  final String? ownerPhone;
  final CompanyListSource source;

  bool get isOwner => relationship.isOwner;

  bool get hasFullAccess => isOwner;
}
