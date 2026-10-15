import { PARTY_CONTACT_IMPORT_TEMPLATE } from './templates';
import { type NotificationContent, renderTemplate } from './types';

export type PartyContactImportNotificationInput = {
  companyName: string;
  importUrl: string;
  expiryMinutes: number;
};

export function buildPartyContactImportNotification(
  input: PartyContactImportNotificationInput,
): NotificationContent {
  const body = renderTemplate(PARTY_CONTACT_IMPORT_TEMPLATE, {
    company_name: input.companyName,
    import_url: input.importUrl,
    expiry_minutes: input.expiryMinutes,
  });

  return {
    type: 'party_contact_import',
    title: 'Import contacts',
    body,
    metadata: {
      companyName: input.companyName,
      expiryMinutes: input.expiryMinutes,
    },
    deepLinks: {
      primary: input.importUrl,
      import: input.importUrl,
    },
  };
}
