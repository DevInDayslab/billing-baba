import { SYNC_SHARE_INVITE_TEMPLATE } from './templates';
import { type NotificationContent, renderTemplate } from './types';

export type SyncShareInviteNotificationInput = {
  companyName: string;
  inviteUrl: string;
  expiryDays: number;
  roleLabel?: string;
  phone?: string | null;
  email?: string | null;
};

export function buildSyncShareInviteNotification(
  input: SyncShareInviteNotificationInput,
): NotificationContent {
  const body = renderTemplate(SYNC_SHARE_INVITE_TEMPLATE, {
    company_name: input.companyName,
    invite_url: input.inviteUrl,
    expiry_days: input.expiryDays,
  });

  return {
    type: 'sync_share_invite',
    title: 'Collaboration invitation',
    body,
    metadata: {
      companyName: input.companyName,
      roleLabel: input.roleLabel ?? null,
      expiryDays: input.expiryDays,
    },
    deepLinks: {
      primary: input.inviteUrl,
      invite: input.inviteUrl,
    },
  };
}
