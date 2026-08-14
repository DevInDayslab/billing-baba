import type { StoragePurpose } from '../storage/storage.constants';
import type { StorageValidationPolicy } from '../storage/storage.types';

export const DOCUMENT_ATTACHMENT_ENTITY_TYPES = [
  'party',
  'sale',
  'purchase',
  'estimate',
  'sale_order',
  'purchase_order',
  'delivery_challan',
  'payment_in',
  'payment_out',
  'expense',
  'job_work',
] as const;

export type DocumentAttachmentEntityType =
  (typeof DOCUMENT_ATTACHMENT_ENTITY_TYPES)[number];

export const MAX_DOCUMENT_ATTACHMENTS = 30;

export const DOCUMENT_ATTACHMENT_POLICY: StorageValidationPolicy = {
  maxBytes: 10 * 1024 * 1024,
  allowedMimes: [
    'image/png',
    'image/jpeg',
    'image/webp',
    'application/pdf',
    'text/plain',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  ],
};

const SALE_DOCUMENT_TYPES = {
  sale: [
    'tax_invoice',
    'bill_of_supply',
    'normal_invoice',
    'pos',
    'sales_return',
  ],
  estimate: ['estimate'],
  sale_order: ['sale_order'],
  delivery_challan: ['delivery_challan'],
} as const;

const PURCHASE_DOCUMENT_TYPES = {
  purchase: ['purchase_bill', 'purchase_return'],
  purchase_order: ['purchase_order'],
} as const;

export function storagePurposeForEntity(
  entityType: DocumentAttachmentEntityType,
): StoragePurpose {
  switch (entityType) {
    case 'sale':
    case 'estimate':
    case 'sale_order':
    case 'delivery_challan':
      return 'sales';
    case 'purchase':
    case 'purchase_order':
      return 'purchases';
    case 'expense':
      return 'expenses';
    case 'payment_in':
    case 'payment_out':
      return 'payments';
    case 'job_work':
      return 'job_work';
    case 'party':
      return 'documents';
    default:
      return 'documents';
  }
}

export function salesDocumentTypesForEntity(
  entityType: DocumentAttachmentEntityType,
): readonly string[] | null {
  if (entityType in SALE_DOCUMENT_TYPES) {
    return SALE_DOCUMENT_TYPES[entityType as keyof typeof SALE_DOCUMENT_TYPES];
  }
  return null;
}

export function purchaseDocumentTypesForEntity(
  entityType: DocumentAttachmentEntityType,
): readonly string[] | null {
  if (entityType in PURCHASE_DOCUMENT_TYPES) {
    return PURCHASE_DOCUMENT_TYPES[
      entityType as keyof typeof PURCHASE_DOCUMENT_TYPES
    ];
  }
  return null;
}

export function paymentDirectionForEntity(
  entityType: DocumentAttachmentEntityType,
): 'received' | 'paid' | null {
  if (entityType === 'payment_in') return 'received';
  if (entityType === 'payment_out') return 'paid';
  return null;
}

export function attachmentKindFromMime(
  mimeType: string,
): 'image' | 'pdf' | 'document' {
  if (mimeType.startsWith('image/')) return 'image';
  if (mimeType === 'application/pdf') return 'pdf';
  return 'document';
}
