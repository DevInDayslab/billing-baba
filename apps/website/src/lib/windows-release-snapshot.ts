import type { WindowsRelease, WindowsReleaseResult } from './windows-release';
import { validateWindowsRelease } from './windows-release';
import snapshot from '../generated/windows-release.snapshot.json';

export type WindowsReleaseSnapshot =
  | {
      status: 'ok';
      manifestUrl: string;
      release: WindowsRelease;
      fetchedAt: string;
    }
  | {
      status: 'unavailable';
      reason?: string;
      manifestUrl?: string;
      fetchedAt: string;
    };

export function loadWindowsReleaseSnapshot(): WindowsReleaseResult {
  const data = snapshot as WindowsReleaseSnapshot;
  if (data.status !== 'ok') {
    return {
      ok: false,
      reason: data.reason ?? 'Release data unavailable',
    };
  }
  return validateWindowsRelease(data.manifestUrl, data.release.manifest);
}

export function getSnapshotManifestUrl(): string | undefined {
  const data = snapshot as WindowsReleaseSnapshot;
  return data.manifestUrl;
}
