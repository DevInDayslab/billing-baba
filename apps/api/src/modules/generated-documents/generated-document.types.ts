import type {
  GeneratedDocumentKind,
  GeneratedDocumentSourceType,
} from './generated-document.constants';

export type GeneratedDocumentRecord = {
  id: string;
  businessId: string;
  documentKind: GeneratedDocumentKind;
  sourceType: GeneratedDocumentSourceType;
  sourceId: string;
  mediaAssetId: string | null;
  sourceVersion: number;
  fileName: string;
  mimeType: string;
  publicToken: string;
  generatedAt: Date;
  createdAt: Date;
  updatedAt: Date;
  createdBy: string | null;
};

export type GeneratedDocumentResponse = {
  id: string;
  document_kind: GeneratedDocumentKind;
  source_type: GeneratedDocumentSourceType;
  source_id: string;
  source_version: number;
  file_name: string;
  mime_type: string;
  public_token: string;
  cached: boolean;
  generated_at: string;
  download_url?: string;
  public_url?: string;
};

export type PublicGeneratedDocumentResponse = {
  token: string;
  document_kind: GeneratedDocumentKind;
  file_name: string;
  mime_type: string;
  generated_at: string;
  download_url: string;
};

export type SourceVersionSnapshot = {
  sourceVersion: number;
};
