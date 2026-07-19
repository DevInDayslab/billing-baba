import type { AppConfig } from '../../config/app_config';
import type {
  BusinessOwnerInfo,
  CompanyMemberDto,
  InvitationDto,
  InvitationPublicDto,
  InvitationRow,
  PendingInvitationDto,
  SharedCompanyDto,
} from './collaboration.types';
import {
  deriveInvitationChannel,
  formatPhoneOrEmail,
  relationshipFromRole,
} from './collaboration.utils';

export function buildInvitationUrl(
  config: Pick<AppConfig, 'websiteUrl'>,
  token: string,
): string {
  const base = config.websiteUrl.replace(/\/$/, '');
  return `${base}/invite/${token}`;
}

export function toInvitationDto(row: InvitationRow): InvitationDto {
  return {
    id: row.id,
    invite_code: row.token,
    member_id: row.placeholderMemberId,
    full_name: row.inviteeName,
    phone_or_email: formatPhoneOrEmail(row.phone, row.email),
    role: row.role,
    channel: deriveInvitationChannel(row.phone, row.email),
    sent_at: row.createdAt.toISOString(),
    expires_at: row.expiresAt.toISOString(),
    status: row.status,
  };
}

export function toInvitationPublicDto(
  row: InvitationRow,
  owner: BusinessOwnerInfo,
  config: Pick<AppConfig, 'websiteUrl'>,
): InvitationPublicDto {
  return {
    id: row.id,
    status: row.status,
    company_name: owner.companyName,
    owner_name: owner.ownerName,
    owner_phone: owner.ownerPhone,
    role: row.role,
    expires_at: row.expiresAt.toISOString(),
    invitation_url: buildInvitationUrl(config, row.token),
  };
}

export function toSharedCompanyDto(
  company: BusinessOwnerInfo,
  role: SharedCompanyDto['role'],
  memberId: string,
): SharedCompanyDto {
  return {
    id: company.companyId,
    member_id: memberId,
    name: company.companyName,
    owner_name: company.ownerName,
    owner_phone: company.ownerPhone,
    relationship: relationshipFromRole(role),
    role,
    sync_status: 'on',
  };
}

export function toPendingInvitationDto(
  row: InvitationRow,
  owner: BusinessOwnerInfo,
  expired: boolean,
): PendingInvitationDto {
  return {
    id: row.id,
    company_id: row.companyId,
    name: owner.companyName,
    owner_name: owner.ownerName,
    owner_phone: owner.ownerPhone,
    relationship: expired ? 'expired_invite' : 'pending_invite',
    role: row.role,
    invitation_id: row.id,
    invite_code: row.token,
    invitation_status: expired ? 'expired' : 'pending',
    expires_at: row.expiresAt.toISOString(),
    sync_status: 'on',
  };
}

function invitationStatusToMemberStatus(
  status: InvitationRow['status'],
): CompanyMemberDto['status'] {
  switch (status) {
    case 'pending':
    case 'opened':
      return 'pending';
    case 'accepted':
      return 'joined';
    case 'left':
      return 'left';
    case 'rejected':
      return 'rejected';
    case 'expired':
      return 'expired';
    case 'cancelled':
      return 'cancelled';
    default:
      return 'pending';
  }
}

export function toOwnerMemberDto(
  owner: BusinessOwnerInfo,
  currentAccountId: string,
  ownerAccountId: string,
): CompanyMemberDto {
  return {
    id: `owner-${owner.companyId}`,
    full_name: owner.ownerName,
    phone_or_email: owner.ownerPhone,
    status: 'joined',
    role: 'secondary_admin',
    is_owner: true,
    is_current_user: currentAccountId === ownerAccountId,
    invitation_id: null,
    invited_at: new Date(0).toISOString(),
    joined_at: null,
  };
}

function contactsMatch(
  invitationPhone: string | null,
  invitationEmail: string | null,
  accountPhone: string,
  accountEmail: string | null,
): boolean {
  const inviteContact = formatPhoneOrEmail(invitationPhone, invitationEmail);
  if (!inviteContact) return false;
  const normalizedInvite = inviteContact.trim().toLowerCase();
  if (invitationEmail && accountEmail) {
    return normalizedInvite === accountEmail.trim().toLowerCase();
  }
  if (invitationPhone) {
    const digits = (value: string) => value.replace(/\D/g, '');
    const inviteDigits = digits(invitationPhone);
    const accountDigits = digits(accountPhone);
    return (
      inviteDigits.length > 0 &&
      accountDigits.length > 0 &&
      inviteDigits.slice(-10) === accountDigits.slice(-10)
    );
  }
  return false;
}

export function invitationToMemberDto(
  row: InvitationRow,
  currentAccount: { phone: string; email: string | null } | null,
): CompanyMemberDto {
  const phoneOrEmail = formatPhoneOrEmail(row.phone, row.email);
  const status = invitationStatusToMemberStatus(row.status);
  const isCurrentUser = currentAccount
    ? contactsMatch(row.phone, row.email, currentAccount.phone, currentAccount.email)
    : false;

  return {
    id: row.placeholderMemberId,
    full_name: row.inviteeName,
    phone_or_email: phoneOrEmail,
    status,
    role: row.role,
    is_owner: false,
    is_current_user: isCurrentUser,
    invitation_id: row.id,
    invited_at: row.createdAt.toISOString(),
    joined_at:
      row.status === 'accepted' || row.status === 'left'
        ? (row.acceptedAt?.toISOString() ?? row.updatedAt.toISOString())
        : null,
  };
}
