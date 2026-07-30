import type { DocumentAttachmentEntityType } from './document-attachment.constants';

export type DocumentAttachmentRecord = {
  id: string;
  business_id: string;
  entity_type: DocumentAttachmentEntityType;
  entity_id: string;
  media_asset_id: string | null;
  file_name: string;
  file_url: string | null;
  mime_type: string;
  attachment_kind: 'image' | 'pdf' | 'document';
  sort_order: number;
  label: string | null;
  created_at: string;
  updated_at: string;
};

export type DocumentAttachmentResponse = DocumentAttachmentRecord & {
  download_url?: string | null;
};

export type CreateDocumentAttachmentInput = {
  mediaAssetId: string;
  fileName: string;
  fileUrl: string;
  mimeType: string;
  attachmentKind: 'image' | 'pdf' | 'document';
  sortOrder?: number;
  label?: string | null;
  createdBy?: string | null;
  updatedBy?: string | null;
};
