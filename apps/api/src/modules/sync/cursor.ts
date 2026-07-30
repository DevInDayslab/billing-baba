import { ZERO_UUID } from './sync.constants';
import { syncInvalidCursor } from './sync.errors';

export type SyncCursorPayload = {
  /** ISO-8601 updated_at watermark */
  t: string;
  /** Entity id tie-breaker */
  i: string;
};

function toBase64Url(value: string): string {
  return Buffer.from(value, 'utf8')
    .toString('base64')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/g, '');
}

function fromBase64Url(value: string): string {
  const padded = value.replace(/-/g, '+').replace(/_/g, '/');
  const padLength = (4 - (padded.length % 4)) % 4;
  return Buffer.from(padded + '='.repeat(padLength), 'base64').toString('utf8');
}

export function encodeCursor(payload: SyncCursorPayload): string {
  return toBase64Url(JSON.stringify(payload));
}

export function decodeCursor(cursor: string): SyncCursorPayload {
  try {
    const raw = fromBase64Url(cursor);
    const parsed: unknown = JSON.parse(raw);
    if (
      typeof parsed !== 'object' ||
      parsed === null ||
      typeof (parsed as SyncCursorPayload).t !== 'string' ||
      typeof (parsed as SyncCursorPayload).i !== 'string'
    ) {
      throw syncInvalidCursor();
    }
    const { t, i } = parsed as SyncCursorPayload;
    if (!t || !i) {
      throw syncInvalidCursor();
    }
    const date = new Date(t);
    if (Number.isNaN(date.getTime())) {
      throw syncInvalidCursor('Cursor timestamp is invalid');
    }
    return { t: date.toISOString(), i };
  } catch (error) {
    if (error instanceof Error && 'code' in error) {
      throw error;
    }
    throw syncInvalidCursor();
  }
}

/** Watermark cursor for empty pull / bootstrap complete. */
export function watermarkCursor(serverTime: Date = new Date()): string {
  return encodeCursor({
    t: serverTime.toISOString(),
    i: ZERO_UUID,
  });
}
