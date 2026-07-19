export type CollaborationRole =
  | 'secondary_admin'
  | 'salesman'
  | 'biller'
  | 'biller_and_salesman'
  | 'accountant'
  | 'accountant_edit_access'
  | 'stock_keeper';

export type InvitationStatus =
  | 'pending'
  | 'opened'
  | 'accepted'
  | 'rejected'
  | 'left'
  | 'expired'
  | 'cancelled';

export type CompanyMemberStatus = 'active' | 'left' | 'removed';

export type InvitationChannel = 'sms' | 'whatsapp' | 'email';

export type CompanyRelationship =
  | 'owner'
  | 'secondary_admin'
  | 'member'
  | 'pending_invite'
  | 'expired_invite';

export type InvitationCardStatus =
  | 'pending'
  | 'accepted'
  | 'rejected'
  | 'cancelled'
  | 'expired';

export type InvitationPublicDto = {
  id: string;
  status: InvitationStatus;
  company_name: string;
  owner_name: string;
  owner_phone: string;
  role: CollaborationRole;
  expires_at: string;
  invitation_url: string;
};

export type InvitationDto = {
  id: string;
  invite_code: string;
  member_id: string;
  full_name: string;
  phone_or_email: string;
  role: CollaborationRole;
  channel: InvitationChannel;
  sent_at: string;
  expires_at: string;
  status: InvitationStatus;
};

export type SharedCompanyDto = {
  id: string;
  member_id: string;
  name: string;
  owner_name: string;
  owner_phone: string;
  relationship: CompanyRelationship;
  role: CollaborationRole;
  sync_status: 'on' | 'off';
};

export type PendingInvitationDto = {
  id: string;
  company_id: string;
  name: string;
  owner_name: string;
  owner_phone: string;
  relationship: 'pending_invite' | 'expired_invite';
  role: CollaborationRole;
  invitation_id: string;
  invite_code: string;
  invitation_status: InvitationCardStatus;
  expires_at: string;
  sync_status: 'on' | 'off';
};

export type AcceptInvitationResult = {
  invitation: InvitationPublicDto;
  member_id: string;
};

export type InvitationRow = {
  id: string;
  companyId: string;
  inviteeName: string;
  phone: string | null;
  email: string | null;
  role: CollaborationRole;
  status: InvitationStatus;
  token: string;
  placeholderMemberId: string;
  createdBy: string;
  openedAt: Date | null;
  acceptedAt: Date | null;
  rejectedAt: Date | null;
  expiresAt: Date;
  supersededBy: string | null;
  createdAt: Date;
  updatedAt: Date;
};

export type CompanyMemberRow = {
  id: string;
  companyId: string;
  accountId: string;
  role: CollaborationRole;
  status: CompanyMemberStatus;
  joinedAt: Date | null;
  leftAt: Date | null;
  createdAt: Date;
  updatedAt: Date;
};

export type BusinessOwnerInfo = {
  companyId: string;
  companyName: string;
  ownerName: string;
  ownerPhone: string;
};
