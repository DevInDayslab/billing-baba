import { mkdir, writeFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildUnavailableSnapshotPayload } from '../src/lib/windows-release-snapshot-default';
import { getLatestWindowsRelease } from '../src/lib/windows-release';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const outPath = join(root, 'src/generated/windows-release.snapshot.json');

function warnOnce(message: string) {
  console.warn(`WARN windows-release snapshot: ${message}`);
}

async function writeSnapshot(payload: Record<string, unknown>) {
  await mkdir(dirname(outPath), { recursive: true });
  await writeFile(outPath, `${JSON.stringify(payload, null, 2)}\n`, 'utf8');
}

async function writeUnavailable(reason: string, manifestUrl?: string) {
  const payload = buildUnavailableSnapshotPayload(reason, manifestUrl);
  await writeSnapshot(payload);
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
    await writeSnapshot(payload);
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
