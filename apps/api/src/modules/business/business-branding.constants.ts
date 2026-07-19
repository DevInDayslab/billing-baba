import type { StorageValidationPolicy } from '../storage/storage.types';

export const BRANDING_KINDS = [
  'logo',
  'signature',
  'stamp',
  'upi_qr',
] as const;

export type BrandingKind = (typeof BRANDING_KINDS)[number];

export const BRANDING_POLICIES: Record<BrandingKind, StorageValidationPolicy> = {
  logo: {
    maxBytes: 2 * 1024 * 1024,
    allowedMimes: ['image/png', 'image/jpeg', 'image/webp'],
  },
  signature: {
    maxBytes: 1024 * 1024,
    allowedMimes: ['image/png'],
  },
  stamp: {
    maxBytes: 1024 * 1024,
    allowedMimes: ['image/png'],
  },
  upi_qr: {
    maxBytes: 1024 * 1024,
    allowedMimes: ['image/png'],
  },
};

export const AVATAR_POLICY: StorageValidationPolicy = {
  maxBytes: 2 * 1024 * 1024,
  allowedMimes: ['image/png', 'image/jpeg', 'image/webp'],
};

export const BRANDING_WRITE_ROLES = ['owner', 'manager'] as const;
