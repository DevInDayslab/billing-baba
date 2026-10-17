import { describe, expect, it, vi } from 'vitest';
import {
  assertManifestUrlPolicy,
  fetchLatestWindowsRelease,
  getLatestWindowsRelease,
  parseWindowsReleaseManifest,
  validateWindowsRelease,
} from './windows-release';

const validManifest = {
  latest_version: '1.0.1',
  latest_build: 2,
  min_supported_build: 1,
  installer_url: 'https://updates.example.com/BillingBabaSetup-v1.0.1.exe',
  sha256: 'abc123',
  release_notes: 'Fixes',
  force_update: false,
  published_at: '2026-10-17T10:00:00Z',
};

const manifestUrl = 'https://updates.example.com/version.json';

describe('parseWindowsReleaseManifest', () => {
  it('parses valid manifest', () => {
    const parsed = parseWindowsReleaseManifest(validManifest);
    expect(parsed.latest_version).toBe('1.0.1');
  });

  it('rejects missing fields', () => {
    expect(() =>
      parseWindowsReleaseManifest({ ...validManifest, sha256: undefined }),
    ).toThrow();
  });

  it('rejects invalid JSON types', () => {
    expect(() =>
      parseWindowsReleaseManifest({ ...validManifest, force_update: 'yes' }),
    ).toThrow();
  });
});

describe('assertManifestUrlPolicy', () => {
  it('rejects http manifest', () => {
    expect(() =>
      assertManifestUrlPolicy('http://updates.example.com/version.json', {
        ...parseWindowsReleaseManifest(validManifest),
        installer_url: 'http://updates.example.com/a.exe',
      }),
    ).toThrow(/HTTPS/);
  });

  it('rejects host mismatch', () => {
    expect(() =>
      assertManifestUrlPolicy(manifestUrl, {
        ...parseWindowsReleaseManifest(validManifest),
        installer_url: 'https://evil.example.com/a.exe',
      }),
    ).toThrow(/host/);
  });
});

describe('validateWindowsRelease', () => {
  it('accepts valid https same-host manifest', () => {
    const result = validateWindowsRelease(
      manifestUrl,
      parseWindowsReleaseManifest(validManifest),
    );
    expect(result.ok).toBe(true);
  });
});

describe('fetchLatestWindowsRelease', () => {
  it('returns null-safe result on invalid JSON', async () => {
    const fetchImpl = vi.fn(async () => ({
      ok: true,
      text: async () => 'not-json',
    })) as unknown as typeof fetch;

    const result = await fetchLatestWindowsRelease(manifestUrl, { fetchImpl });
    expect(result.ok).toBe(false);
  });

  it('returns timeout reason', async () => {
    const fetchImpl = vi.fn(
      () =>
        new Promise<Response>((_resolve, reject) => {
          const err = new Error('aborted');
          err.name = 'AbortError';
          reject(err);
        }),
    ) as unknown as typeof fetch;

    const result = await fetchLatestWindowsRelease(manifestUrl, {
      fetchImpl,
      timeoutMs: 10,
    });
    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.reason).toMatch(/timed out/i);
    }
  });
});

describe('getLatestWindowsRelease', () => {
  it('handles empty manifest URL', async () => {
    const result = await getLatestWindowsRelease('');
    expect(result.ok).toBe(false);
  });

  it('handles whitespace-only manifest URL', async () => {
    const result = await getLatestWindowsRelease('   ');
    expect(result.ok).toBe(false);
  });

  it('rejects http manifest URL without fetching', async () => {
    const result = await getLatestWindowsRelease(
      'http://updates.example.com/version.json',
    );
    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.reason).toMatch(/HTTPS/i);
    }
  });
});

describe('fetchLatestWindowsRelease error cases', () => {
  it('returns failure on 404', async () => {
    const fetchImpl = vi.fn(async () => ({
      ok: false,
      status: 404,
      text: async () => '',
    })) as unknown as typeof fetch;
    const result = await fetchLatestWindowsRelease(manifestUrl, { fetchImpl });
    expect(result.ok).toBe(false);
  });

  it('returns failure on 500', async () => {
    const fetchImpl = vi.fn(async () => ({
      ok: false,
      status: 500,
      text: async () => 'err',
    })) as unknown as typeof fetch;
    const result = await fetchLatestWindowsRelease(manifestUrl, { fetchImpl });
    expect(result.ok).toBe(false);
  });

  it('returns failure on host mismatch after parse', async () => {
    const fetchImpl = vi.fn(async () => ({
      ok: true,
      text: async () =>
        JSON.stringify({
          ...validManifest,
          installer_url: 'https://evil.example.com/BillingBabaSetup-v1.0.1.exe',
        }),
    })) as unknown as typeof fetch;
    const result = await fetchLatestWindowsRelease(manifestUrl, { fetchImpl });
    expect(result.ok).toBe(false);
  });

  it('returns failure on missing required fields', async () => {
    const fetchImpl = vi.fn(async () => ({
      ok: true,
      text: async () => JSON.stringify({ latest_version: '1.0.0' }),
    })) as unknown as typeof fetch;
    const result = await fetchLatestWindowsRelease(manifestUrl, { fetchImpl });
    expect(result.ok).toBe(false);
  });
});
