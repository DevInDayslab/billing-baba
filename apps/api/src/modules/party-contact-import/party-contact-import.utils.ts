import QRCode from 'qrcode';
import type { AppConfig } from '../../config/app_config';
import { generateInvoiceShareToken } from '../invoice-share/invoice-share.utils';

export const MAX_PARTY_CONTACT_IMPORT_ROWS = 500;

export function generatePartyContactImportToken(): string {
  return generateInvoiceShareToken();
}

export function buildPartyContactImportWebUrl(
  config: Pick<AppConfig, 'websiteUrl'>,
  token: string,
): string {
  const base = config.websiteUrl.replace(/\/$/, '');
  return `${base}/import-contacts/${token}`;
}

export function buildPartyContactImportDeepLink(token: string): string {
  return `billingbaba://import-contacts/${token}`;
}

export async function buildUrlQrDataUrl(url: string): Promise<string> {
  return QRCode.toDataURL(url, {
    width: 320,
    margin: 2,
    errorCorrectionLevel: 'M',
  });
}

export function addMinutes(date: Date, minutes: number): Date {
  return new Date(date.getTime() + minutes * 60 * 1000);
}
