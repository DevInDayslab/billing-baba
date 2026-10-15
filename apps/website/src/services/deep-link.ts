export function inviteDeepLink(token: string): string {
  return `billingbaba://invite/${token}`;
}

export function importContactsDeepLink(token: string): string {
  return `billingbaba://import-contacts/${token}`;
}

export function tryOpenApp(token: string): void {
  window.location.href = inviteDeepLink(token);
}

export function tryOpenImportContactsApp(token: string): void {
  window.location.href = importContactsDeepLink(token);
}

export const DOWNLOAD_URL = 'https://billingbaba.com/download';
