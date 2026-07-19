export const GENERATED_DOCUMENT_KINDS = [
  'invoice_pdf',
  'estimate_pdf',
  'receipt_pdf',
  'delivery_challan_pdf',
  'purchase_pdf',
  'report_pdf',
  'excel',
  'csv',
] as const;

export type GeneratedDocumentKind = (typeof GENERATED_DOCUMENT_KINDS)[number];

export const GENERATED_SOURCE_TYPES = [
  'sale_document',
  'purchase_document',
  'payment',
  'report',
] as const;

export type GeneratedDocumentSourceType =
  (typeof GENERATED_SOURCE_TYPES)[number];

export const GENERATED_DOCUMENT_MIME_TYPES = [
  'application/pdf',
  'text/csv',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
] as const;

export type GeneratedDocumentMimeType =
  (typeof GENERATED_DOCUMENT_MIME_TYPES)[number];

export const GENERATED_MIME_EXTENSIONS: Record<GeneratedDocumentMimeType, string> =
  {
    'application/pdf': 'pdf',
    'text/csv': 'csv',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': 'xlsx',
  };

export const MIME_FOR_GENERATED_KIND: Record<
  GeneratedDocumentKind,
  GeneratedDocumentMimeType
> = {
  invoice_pdf: 'application/pdf',
  estimate_pdf: 'application/pdf',
  receipt_pdf: 'application/pdf',
  delivery_challan_pdf: 'application/pdf',
  purchase_pdf: 'application/pdf',
  report_pdf: 'application/pdf',
  excel: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  csv: 'text/csv',
};

export const GENERATED_DOCUMENT_POLICY = {
  allowedMimes: GENERATED_DOCUMENT_MIME_TYPES,
  maxBytes: 20 * 1024 * 1024,
} as const;

export function storagePurposeForGeneratedKind(
  kind: GeneratedDocumentKind,
): 'sales' | 'purchases' | 'payments' | 'reports' | 'documents' {
  switch (kind) {
    case 'invoice_pdf':
    case 'estimate_pdf':
    case 'delivery_challan_pdf':
      return 'sales';
    case 'purchase_pdf':
      return 'purchases';
    case 'receipt_pdf':
      return 'payments';
    case 'report_pdf':
    case 'excel':
    case 'csv':
      return 'reports';
    default:
      return 'documents';
  }
}

export function ownerTypeForGeneratedKind(kind: GeneratedDocumentKind): string {
  return `generated_${kind}`;
}
