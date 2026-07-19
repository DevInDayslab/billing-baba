export const STORAGE_PURPOSES = [
  'branding',
  'items',
  'parties',
  'sales',
  'purchases',
  'expenses',
  'reports',
  'backups',
  'documents',
  'payments',
  'job_work',
  'other',
] as const;

export type StoragePurpose = (typeof STORAGE_PURPOSES)[number];

export const STORAGE_VISIBILITIES = [
  'private',
  'authenticated',
  'public',
] as const;

export type StorageVisibility = (typeof STORAGE_VISIBILITIES)[number];

export const STORAGE_ASSET_STATUSES = ['pending', 'ready'] as const;

export type StorageAssetStatus = (typeof STORAGE_ASSET_STATUSES)[number];

export const ALLOWED_STORAGE_MIME_TYPES = [
  'image/png',
  'image/jpeg',
  'image/webp',
  'application/pdf',
] as const;

export type AllowedStorageMimeType =
  (typeof ALLOWED_STORAGE_MIME_TYPES)[number];

export const MIME_TO_EXTENSION: Record<AllowedStorageMimeType, string> = {
  'image/png': 'png',
  'image/jpeg': 'jpg',
  'image/webp': 'webp',
  'application/pdf': 'pdf',
};

/** Maps purpose → path segment under businesses/{id}/ */
export const PURPOSE_PATH_SEGMENTS: Record<StoragePurpose, string> = {
  branding: 'branding',
  items: 'items',
  parties: 'parties',
  sales: 'sales',
  purchases: 'purchases',
  expenses: 'expenses',
  reports: 'reports',
  backups: 'backups',
  documents: 'documents',
  payments: 'payments',
  job_work: 'job-work',
  other: 'other',
};
