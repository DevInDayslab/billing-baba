/**
 * Windows desktop release manifest (same shape as apps/client version.json).
 * Validation mirrors the desktop updater: HTTPS only, installer host == manifest host.
 */

export type WindowsReleaseManifest = {
  latest_version: string;
  latest_build: number;
  min_supported_build: number;
  installer_url: string;
  sha256: string;
  release_notes: string;
  force_update: boolean;
  published_at?: string;
};

export type WindowsRelease = {
  manifest: WindowsReleaseManifest;
  manifestUrl: string;
  publishedAt: Date | null;
};

export type WindowsReleaseResult =
  | { ok: true; release: WindowsRelease }
  | { ok: false; reason: string };

const FETCH_TIMEOUT_MS = 5000;

function requireString(json: Record<string, unknown>, key: string): string {
  const value = json[key];
  if (typeof value !== 'string') {
    throw new Error(`Invalid or missing ${key}`);
  }
  return value;
}

function requireInt(json: Record<string, unknown>, key: string): number {
  const value = json[key];
  if (typeof value === 'number' && Number.isFinite(value)) {
    return Math.trunc(value);
  }
  throw new Error(`Invalid or missing ${key}`);
}

export function parseWindowsReleaseManifest(
  json: unknown,
): WindowsReleaseManifest {
  if (typeof json !== 'object' || json === null) {
    throw new Error('Manifest root must be an object');
  }
  const record = json as Record<string, unknown>;
  const latestVersion = requireString(record, 'latest_version').trim();
  const installerUrl = requireString(record, 'installer_url').trim();
  const sha256 = requireString(record, 'sha256').trim();
  const releaseNotes = requireString(record, 'release_notes');
  const forceUpdate = record.force_update;
  if (typeof forceUpdate !== 'boolean') {
    throw new Error('Invalid or missing force_update');
  }
  if (!latestVersion || !installerUrl || !sha256) {
    throw new Error('Empty required manifest field');
  }

  let publishedAt: string | undefined;
  const publishedRaw = record.published_at;
  if (publishedRaw !== undefined && publishedRaw !== null) {
    if (typeof publishedRaw !== 'string' || !publishedRaw.trim()) {
      throw new Error('Invalid published_at');
    }
    publishedAt = publishedRaw;
    const parsed = Date.parse(publishedAt);
    if (Number.isNaN(parsed)) {
      throw new Error('Invalid published_at');
    }
  }

  return {
    latest_version: latestVersion,
    latest_build: requireInt(record, 'latest_build'),
    min_supported_build: requireInt(record, 'min_supported_build'),
    installer_url: installerUrl,
    sha256: sha256,
    release_notes: releaseNotes,
    force_update: forceUpdate,
    published_at: publishedAt,
  };
}

export function assertManifestUrlPolicy(
  manifestUrl: string,
  manifest: WindowsReleaseManifest,
): void {
  const manifestUri = new URL(manifestUrl);
  if (manifestUri.protocol !== 'https:') {
    throw new Error('Manifest URL must use HTTPS');
  }
  const installerUri = new URL(manifest.installer_url);
  if (installerUri.protocol !== 'https:') {
    throw new Error('Installer URL must use HTTPS');
  }
  if (installerUri.host !== manifestUri.host) {
    throw new Error('Installer host must match manifest host');
  }
}

export function validateWindowsRelease(
  manifestUrl: string,
  manifest: WindowsReleaseManifest,
): WindowsReleaseResult {
  try {
    assertManifestUrlPolicy(manifestUrl, manifest);
    const publishedAt =
      manifest.published_at != null
        ? new Date(manifest.published_at)
        : null;
    return {
      ok: true,
      release: {
        manifest,
        manifestUrl,
        publishedAt:
          publishedAt != null && !Number.isNaN(publishedAt.getTime())
            ? publishedAt
            : null,
      },
    };
  } catch (e) {
    const message = e instanceof Error ? e.message : String(e);
    return { ok: false, reason: message };
  }
}

export async function fetchLatestWindowsRelease(
  manifestUrl: string,
  options?: { fetchImpl?: typeof fetch; timeoutMs?: number },
): Promise<WindowsReleaseResult> {
  const fetchImpl = options?.fetchImpl ?? fetch;
  const timeoutMs = options?.timeoutMs ?? FETCH_TIMEOUT_MS;

  let parsed: URL;
  try {
    parsed = new URL(manifestUrl);
  } catch {
    return { ok: false, reason: 'Invalid manifest URL' };
  }
  if (parsed.protocol !== 'https:') {
    return { ok: false, reason: 'Manifest URL must use HTTPS' };
  }

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);

  try {
    const response = await fetchImpl(manifestUrl, {
      signal: controller.signal,
      headers: { Accept: 'application/json' },
    });
    if (!response.ok) {
      return { ok: false, reason: `HTTP ${response.status}` };
    }
    const body = await response.text();
    if (!body.trim()) {
      return { ok: false, reason: 'Empty manifest body' };
    }
    const json = JSON.parse(body) as unknown;
    const manifest = parseWindowsReleaseManifest(json);
    return validateWindowsRelease(manifestUrl, manifest);
  } catch (e) {
    if (e instanceof Error && e.name === 'AbortError') {
      return { ok: false, reason: 'Request timed out' };
    }
    const message = e instanceof Error ? e.message : String(e);
    return { ok: false, reason: message };
  } finally {
    clearTimeout(timer);
  }
}

/** Build-time / snapshot entry point (never throws). */
export async function getLatestWindowsRelease(
  manifestUrl: string | undefined,
  options?: { fetchImpl?: typeof fetch },
): Promise<WindowsReleaseResult> {
  const trimmed = manifestUrl?.trim() ?? '';
  if (!trimmed) {
    return { ok: false, reason: 'WEBSITE_UPDATE_MANIFEST_URL is not set' };
  }
  return fetchLatestWindowsRelease(trimmed, options);
}
