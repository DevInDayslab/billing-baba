/** Default marketing site used for links opened on external devices (phones, SMS). */
export const DEFAULT_PUBLIC_WEBSITE_URL = 'https://billingbaba.com';

function isLocalDevWebsiteHost(hostname: string): boolean {
  const host = hostname.toLowerCase();
  return (
    host === 'localhost' ||
    host === '127.0.0.1' ||
    host === '[::1]' ||
    host.endsWith('.local')
  );
}

/**
 * URLs shared via QR codes or SMS must be reachable from a phone, not the dev machine.
 * When WEBSITE_URL points at localhost, fall back to the public marketing domain.
 */
export function resolvePublicWebsiteUrl(websiteUrl: string): string {
  const trimmed = websiteUrl.trim();
  if (!trimmed) {
    return DEFAULT_PUBLIC_WEBSITE_URL;
  }

  try {
    const { hostname } = new URL(trimmed);
    if (isLocalDevWebsiteHost(hostname)) {
      return DEFAULT_PUBLIC_WEBSITE_URL;
    }
  } catch {
    return DEFAULT_PUBLIC_WEBSITE_URL;
  }

  return trimmed.replace(/\/$/, '');
}
