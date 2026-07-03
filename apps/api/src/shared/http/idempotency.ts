const processedIdempotencyKeys = new Set<string>();

export { processedIdempotencyKeys };

export function consumeIdempotencyKey(key: string | undefined): boolean {
  if (!key) {
    return true;
  }

  if (processedIdempotencyKeys.has(key)) {
    return false;
  }

  processedIdempotencyKeys.add(key);
  return true;
}
