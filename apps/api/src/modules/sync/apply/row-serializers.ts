/** Convert camelCase ↔ snake_case for sync wire payloads. */

export function camelToSnake(key: string): string {
  return key.replace(/[A-Z]/g, (letter) => `_${letter.toLowerCase()}`);
}

export function snakeToCamel(key: string): string {
  return key.replace(/_([a-z])/g, (_, letter: string) => letter.toUpperCase());
}

const SYNC_META_CAMEL = new Set([
  'id',
  'businessId',
  'createdAt',
  'updatedAt',
  'deletedAt',
  'isDeleted',
  'createdBy',
  'updatedBy',
  'syncVersion',
  'deviceId',
]);

export function rowToWirePayload(
  row: Record<string, unknown>,
): Record<string, unknown> {
  const out: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(row)) {
    if (SYNC_META_CAMEL.has(key)) continue;
    out[camelToSnake(key)] = serializeValue(value);
  }
  return out;
}

export function wirePayloadToDomainValues(
  payload: Record<string, unknown>,
  allowedCamelKeys: readonly string[],
): Record<string, unknown> {
  const allowed = new Set(allowedCamelKeys);
  const out: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(payload)) {
    const camel = snakeToCamel(key);
    if (SYNC_META_CAMEL.has(camel)) continue;
    if (!allowed.has(camel)) continue;
    out[camel] = deserializeValue(value, camel);
  }
  return out;
}

function serializeValue(value: unknown): unknown {
  if (value instanceof Date) {
    return value.toISOString();
  }
  return value;
}

function deserializeValue(value: unknown, camelKey: string): unknown {
  if (typeof value !== 'string') {
    return value;
  }

  if (camelKey === 'documentDate' || camelKey.endsWith('At')) {
    const parsed = new Date(value);
    if (!Number.isNaN(parsed.getTime())) {
      return parsed;
    }
  }

  if (camelKey === 'dueDate' || camelKey === 'connectedSince') {
    const dateOnly = value.match(/^(\d{4}-\d{2}-\d{2})/);
    if (dateOnly) {
      return dateOnly[1];
    }
  }

  return value;
}
