import type { StorageValidationPolicy } from '../storage/storage.types';

export const ITEM_IMAGE_POLICY: StorageValidationPolicy = {
  maxBytes: 2 * 1024 * 1024,
  allowedMimes: ['image/png', 'image/jpeg', 'image/webp'],
};

export const RACK_PHOTO_POLICY: StorageValidationPolicy = {
  maxBytes: 2 * 1024 * 1024,
  allowedMimes: ['image/png', 'image/jpeg', 'image/webp'],
};

/** Maximum gallery images per item (excluding rack photos). */
export const MAX_ITEM_GALLERY_IMAGES = 20;
