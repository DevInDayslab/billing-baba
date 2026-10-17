import type { WindowsReleaseSnapshot } from './windows-release-snapshot';

/** Committed fallback when prebuild has not run yet (fresh clone). */
export const DEFAULT_WINDOWS_RELEASE_SNAPSHOT: WindowsReleaseSnapshot = {
  status: 'unavailable',
  reason: 'No release snapshot yet',
  fetchedAt: '1970-01-01T00:00:00.000Z',
};

export function buildUnavailableSnapshotPayload(
  reason: string,
  manifestUrl?: string,
): WindowsReleaseSnapshot {
  return {
    status: 'unavailable',
    reason,
    manifestUrl: manifestUrl ?? undefined,
    fetchedAt: new Date().toISOString(),
  };
}
