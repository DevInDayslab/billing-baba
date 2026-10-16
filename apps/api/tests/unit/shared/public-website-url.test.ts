import { describe, expect, test } from 'bun:test';
import {
  DEFAULT_PUBLIC_WEBSITE_URL,
  resolvePublicWebsiteUrl,
} from '../../../src/shared/utils/public-website-url';
import { buildPartyContactImportWebUrl } from '../../../src/modules/party-contact-import/party-contact-import.utils';

describe('resolvePublicWebsiteUrl', () => {
  test('uses configured URL when it is publicly reachable', () => {
    expect(resolvePublicWebsiteUrl('https://billingbaba.com/')).toBe(
      'https://billingbaba.com',
    );
    expect(resolvePublicWebsiteUrl('https://staging.example.com')).toBe(
      'https://staging.example.com',
    );
  });

  test('falls back when WEBSITE_URL is localhost', () => {
    expect(resolvePublicWebsiteUrl('http://localhost:5173')).toBe(
      DEFAULT_PUBLIC_WEBSITE_URL,
    );
    expect(resolvePublicWebsiteUrl('http://127.0.0.1:8080')).toBe(
      DEFAULT_PUBLIC_WEBSITE_URL,
    );
  });
});

describe('buildPartyContactImportWebUrl', () => {
  test('builds import path with public base when config is local', () => {
    const url = buildPartyContactImportWebUrl(
      { websiteUrl: 'http://localhost:5173' },
      'test-token',
    );
    expect(url).toBe(
      `${DEFAULT_PUBLIC_WEBSITE_URL}/import-contacts/test-token`,
    );
  });
});
