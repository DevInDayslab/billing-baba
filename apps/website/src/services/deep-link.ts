export function inviteDeepLink(token: string): string {
  return `billingbaba://invite/${token}`;
}

export function tryOpenApp(token: string): void {
  window.location.href = inviteDeepLink(token);
}

export const DOWNLOAD_URL =
  import.meta.env.VITE_APP_DOWNLOAD_URL ?? 'https://billingbaba.com/download';
