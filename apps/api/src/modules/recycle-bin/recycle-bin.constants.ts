export const RECYCLE_BIN_RETENTION_DAYS = 90;

export const RECYCLE_BIN_ENTITY_TYPES = [
  'sales_document',
  'purchase_document',
  'payment',
  'expense',
  'other_income',
  'loan_transaction',
] as const;

export type RecycleBinEntityType = (typeof RECYCLE_BIN_ENTITY_TYPES)[number];

export function isRecycleBinEntityType(
  value: string,
): value is RecycleBinEntityType {
  return (RECYCLE_BIN_ENTITY_TYPES as readonly string[]).includes(value);
}

export function recycleBinRetentionCutoff(): Date {
  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - RECYCLE_BIN_RETENTION_DAYS);
  return cutoff;
}

export function daysRemaining(deletedAt: Date): number {
  const expiresAt = new Date(deletedAt);
  expiresAt.setDate(expiresAt.getDate() + RECYCLE_BIN_RETENTION_DAYS);
  const ms = expiresAt.getTime() - Date.now();
  return Math.max(0, Math.ceil(ms / (24 * 60 * 60 * 1000)));
}
