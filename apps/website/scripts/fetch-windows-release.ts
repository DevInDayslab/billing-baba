import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { DEFAULT_WINDOWS_RELEASE_SNAPSHOT } from '../src/lib/windows-release-snapshot-default';
import { getLatestWindowsRelease } from '../src/lib/windows-release';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const outPath = join(root, 'src/generated/windows-release.snapshot.json');

function warnOnce(message: string) {
  console.warn(`WARN windows-release snapshot: ${message}`);
}

function snapshotComparableJson(payload: Record<string, unknown>): string {
  const { fetchedAt: _fetchedAt, ...rest } = payload;
  return JSON.stringify(rest);
}

async function writeSnapshotIfChanged(payload: Record<string, unknown>) {
  const nextBody = `${JSON.stringify(payload, null, 2)}\n`;
  let existingRaw = '';
  try {
    existingRaw = await readFile(outPath, 'utf8');
  } catch {
    // missing file — write below
  }

  if (existingRaw) {
    try {
      const existing = JSON.parse(existingRaw) as Record<string, unknown>;
      if (snapshotComparableJson(existing) === snapshotComparableJson(payload)) {
        return;
      }
    } catch {
      // corrupt existing — overwrite
    }
  }

  await mkdir(dirname(outPath), { recursive: true });
  await writeFile(outPath, nextBody, 'utf8');
}

function unavailablePayload(reason: string, manifestUrl?: string): Record<string, unknown> {
  const payload: Record<string, unknown> = {
    status: 'unavailable',
    reason,
  };
  if (manifestUrl) {
    payload.manifestUrl = manifestUrl;
  }
  return payload;
}

const defaultUnavailablePayload = (): Record<string, unknown> => {
  const { fetchedAt: _fetchedAt, manifestUrl: _manifestUrl, ...rest } =
    DEFAULT_WINDOWS_RELEASE_SNAPSHOT;
  return { ...rest };
};

async function writeUnavailable(reason: string, manifestUrl?: string) {
  const payload = manifestUrl
    ? unavailablePayload(reason, manifestUrl)
    : defaultUnavailablePayload();
  await writeSnapshotIfChanged(payload);
  warnOnce(reason);
}

async function run() {
  const raw = process.env.WEBSITE_UPDATE_MANIFEST_URL;
  const manifestUrl = raw?.trim() ?? '';

  if (!manifestUrl) {
    await writeUnavailable('WEBSITE_UPDATE_MANIFEST_URL is not set');
    return;
  }

  try {
    const result = await getLatestWindowsRelease(manifestUrl);
    if (!result.ok) {
      await writeUnavailable(result.reason, manifestUrl);
      return;
    }

    const payload = {
      status: 'ok' as const,
      manifestUrl,
      release: result.release,
      fetchedAt: new Date().toISOString(),
    };
    await writeSnapshotIfChanged(payload);
    console.log('windows-release snapshot: ok');
  } catch {
    await writeUnavailable('Unexpected error while fetching manifest', manifestUrl);
  }
}

try {
  await run();
} catch {
  try {
    await writeUnavailable('Unexpected error at top level');
  } catch {
    // last resort — still exit 0 so Vercel build continues
  }
}
process.exit(0);
