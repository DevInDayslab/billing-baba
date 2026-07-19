import 'package:billing_baba/features/business/models/business_model.dart'
    as business;
import 'package:billing_baba/features/collaboration/domain/models/company_relationship.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';

enum CompanyListSource {
  apiOwned,
  collaborationFake,
  collaborationApi,
}

/// Unified card model for the business list (owned API + fake shared/pending).
class CompanyListEntry {
  const CompanyListEntry({
    required this.id,
    required this.name,
    required this.relationship,
    required this.syncStatus,
    required this.source,
    this.ownerName,
    this.ownerPhone,
    this.role,
    this.invitationId,
    this.invitationStatus,
    this.inviteCode,
    this.memberId,
    this.lastSaleAt,
    this.isCurrent = false,
    this.gstin,
    this.phone,
    this.email,
    this.address,
  });

  final String id;
  final String name;
  final String? ownerName;
  final String? ownerPhone;
  final CompanyRelationship relationship;
  final Role? role;
  final String? invitationId;
  final InvitationCardStatus? invitationStatus;
  final String? inviteCode;
  final String? memberId;
  final business.SyncStatus syncStatus;
  final CompanyListSource source;
  final DateTime? lastSaleAt;
  final bool isCurrent;
  final String? gstin;
  final String? phone;
  final String? email;
  final String? address;

  bool get isOwner => relationship.isOwner;

  bool get isSharedTab =>
      relationship.isPending ||
      relationship.isExpired ||
      relationship.isShared ||
      relationship == CompanyRelationship.secondaryAdmin;

  CompanyListEntry copyWith({
    String? id,
    String? name,
    String? ownerName,
    String? ownerPhone,
    CompanyRelationship? relationship,
    Role? role,
    String? invitationId,
    InvitationCardStatus? invitationStatus,
    String? inviteCode,
    String? memberId,
    business.SyncStatus? syncStatus,
    CompanyListSource? source,
    DateTime? lastSaleAt,
    bool? isCurrent,
    String? gstin,
    String? phone,
    String? email,
    String? address,
  }) {
    return CompanyListEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      relationship: relationship ?? this.relationship,
      role: role ?? this.role,
      invitationId: invitationId ?? this.invitationId,
      invitationStatus: invitationStatus ?? this.invitationStatus,
      inviteCode: inviteCode ?? this.inviteCode,
      memberId: memberId ?? this.memberId,
      syncStatus: syncStatus ?? this.syncStatus,
      source: source ?? this.source,
      lastSaleAt: lastSaleAt ?? this.lastSaleAt,
      isCurrent: isCurrent ?? this.isCurrent,
      gstin: gstin ?? this.gstin,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }

  static CompanyListEntry fromBusinessModel(business.BusinessModel model) {
    return CompanyListEntry(
      id: model.id,
      name: model.name,
      ownerName: model.ownerName,
      relationship: model.isShared
          ? CompanyRelationship.member
          : CompanyRelationship.owner,
      role: model.role != null ? RoleX.fromDisplayLabel(model.role!) : null,
      syncStatus: model.syncStatus,
      source: CompanyListSource.apiOwned,
      lastSaleAt: model.lastSaleAt,
      isCurrent: model.isCurrent,
      gstin: model.gstin,
      phone: model.phone,
      email: model.email,
      address: model.address,
    );
  }
}
