import type { StorageValidationPolicy } from '../storage/storage.types';

/** Same limits as account avatars / business logos. */
export const PARTY_PROFILE_IMAGE_POLICY: StorageValidationPolicy = {
  maxBytes: 2 * 1024 * 1024,
  allowedMimes: ['image/png', 'image/jpeg', 'image/webp'],
};

export const PARTY_PROFILE_OWNER_TYPE = 'party' as const;
