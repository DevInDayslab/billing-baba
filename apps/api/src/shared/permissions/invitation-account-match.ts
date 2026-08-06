import { normalizePhone } from '../utils/phone-number';

export function accountMatchesInvitationContact(
  account: { phone: string; email: string | null },
  invitation: { phone: string | null; email: string | null },
): boolean {
  if (invitation.phone) {
    const accountPhone = normalizePhone(account.phone);
    const invitePhone = normalizePhone(invitation.phone);
    if (accountPhone === invitePhone) {
      return true;
    }
  }

  if (invitation.email && account.email) {
    return (
      account.email.trim().toLowerCase() ===
      invitation.email.trim().toLowerCase()
    );
  }

  return false;
}
