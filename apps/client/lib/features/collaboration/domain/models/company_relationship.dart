/// How the current user relates to a company on the business list.
enum CompanyRelationship {
  owner,
  secondaryAdmin,
  member,
  pendingInvite,
  expiredInvite,
}

/// Invitation lifecycle shown on shared-company cards.
enum InvitationCardStatus {
  pending,
  accepted,
  rejected,
  cancelled,
  expired,
}

extension CompanyRelationshipX on CompanyRelationship {
  bool get isOwner => this == CompanyRelationship.owner;

  bool get isShared =>
      this == CompanyRelationship.secondaryAdmin ||
      this == CompanyRelationship.member;

  bool get isPending => this == CompanyRelationship.pendingInvite;

  bool get isExpired => this == CompanyRelationship.expiredInvite;

  bool get canOpen =>
      isOwner || isShared || this == CompanyRelationship.secondaryAdmin;
}

extension InvitationCardStatusX on InvitationCardStatus {
  bool get isVisibleOnList =>
      this != InvitationCardStatus.rejected &&
      this != InvitationCardStatus.cancelled;
}
