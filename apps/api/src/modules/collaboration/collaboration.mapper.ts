import type { AppConfig } from '../../config/app_config';
import type {
  BusinessOwnerInfo,
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
