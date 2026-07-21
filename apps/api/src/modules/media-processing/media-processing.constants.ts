import type { StoragePurpose } from '../storage/storage.constants';
import { isSourceImageMimeType } from './image/image.constants';
import type { ResolvePolicyInput } from './media-processing.types';

export type ImagePolicyKey =
  | 'ITEM_IMAGE'
  | 'RACK_PHOTO'
  | 'LOGO'
  | 'AVATAR'
  | 'ATTACHMENT'
  | 'PDF'
  | 'OCR_SOURCE'
  | 'SKIP';

export type ImagePolicy = {
  key: ImagePolicyKey;
  optimize: boolean;
  keepOriginal: boolean;
  generateVariants: boolean;
  maxEdge: number | null;
  resize: boolean;
  preserveTransparency?: boolean;
};

export const IMAGE_POLICIES: Record<
  Exclude<ImagePolicyKey, 'SKIP'>,
  ImagePolicy
> = {
  ITEM_IMAGE: {
    key: 'ITEM_IMAGE',
    optimize: true,
    keepOriginal: false,
    generateVariants: true,
    maxEdge: 1600,
    resize: true,
  },
  RACK_PHOTO: {
    key: 'RACK_PHOTO',
    optimize: true,
    keepOriginal: false,
    generateVariants: true,
    maxEdge: 1600,
    resize: true,
  },
  LOGO: {
    key: 'LOGO',
    optimize: true,
    keepOriginal: false,
    generateVariants: true,
    maxEdge: 1024,
    resize: true,
    preserveTransparency: true,
  },
  AVATAR: {
    key: 'AVATAR',
    optimize: true,
    keepOriginal: false,
    generateVariants: true,
    maxEdge: 512,
    resize: true,
  },
  ATTACHMENT: {
    key: 'ATTACHMENT',
    optimize: true,
    keepOriginal: false,
    generateVariants: false,
    maxEdge: null,
    resize: false,
  },
  PDF: {
    key: 'PDF',
    optimize: false,
    keepOriginal: true,
    generateVariants: false,
    maxEdge: null,
    resize: false,
  },
  OCR_SOURCE: {
    key: 'OCR_SOURCE',
    optimize: false,
    keepOriginal: true,
    generateVariants: false,
    maxEdge: null,
    resize: false,
  },
};

const ATTACHMENT_PURPOSES: StoragePurpose[] = [
  'sales',
  'purchases',
  'expenses',
  'payments',
  'job_work',
  'documents',
  'other',
];

export function resolveImagePolicy(input: ResolvePolicyInput): ImagePolicy {
  if (input.purpose === 'derivatives') {
    return { ...IMAGE_POLICIES.PDF, key: 'SKIP', optimize: false };
  }

  if (input.mimeType === 'application/pdf') {
    return IMAGE_POLICIES.PDF;
  }

  if (!isSourceImageMimeType(input.mimeType)) {
    return { ...IMAGE_POLICIES.PDF, key: 'SKIP', optimize: false };
  }

  if (input.ownerType === 'avatar' || input.businessId === null) {
    return IMAGE_POLICIES.AVATAR;
  }

  if (input.purpose === 'branding') {
    return IMAGE_POLICIES.LOGO;
  }

  // Party profile photos use the same thumb/medium/original pipeline as avatars.
  // Other party-scoped uploads (KYC attachments) stay attachment-only.
  if (input.purpose === 'parties') {
    if (input.ownerType === 'party' || input.ownerType === 'profile') {
      return IMAGE_POLICIES.AVATAR;
    }
    return IMAGE_POLICIES.ATTACHMENT;
  }

  if (input.purpose === 'items') {
    if (
      input.ownerType === 'item_location' ||
      input.ownerType === 'location' ||
      input.ownerType === 'rack'
    ) {
      return IMAGE_POLICIES.RACK_PHOTO;
    }
    return IMAGE_POLICIES.ITEM_IMAGE;
  }

  if (ATTACHMENT_PURPOSES.includes(input.purpose)) {
    return IMAGE_POLICIES.ATTACHMENT;
  }

  return IMAGE_POLICIES.ITEM_IMAGE;
}

export function shouldProcessAsset(input: ResolvePolicyInput): boolean {
  const policy = resolveImagePolicy(input);
  return policy.key !== 'SKIP' && policy.optimize;
}
