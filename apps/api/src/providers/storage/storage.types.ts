/**
 * Provider-level DTOs for object storage.
 * Must not expose AWS SDK types outside RailwayS3Provider.
 */

export type CreateUploadUrlParams = {
  key: string;
  mimeType: string;
  expiresInSeconds: number;
  /** Declared content length for signed PUT (optional headers). */
  contentLength?: number;
};

export type CreateUploadUrlResult = {
  url: string;
  headers: Record<string, string>;
  expiresAt: Date;
};

export type CreateDownloadUrlParams = {
  key: string;
  expiresInSeconds: number;
};

export type CreateDownloadUrlResult = {
  url: string;
  expiresAt: Date;
};

export type HeadObjectResult = {
  exists: boolean;
  contentType?: string;
  contentLength?: number;
  etag?: string;
  lastModified?: Date;
};

export type CopyObjectParams = {
  sourceKey: string;
  destinationKey: string;
};

export type MoveObjectParams = {
  sourceKey: string;
  destinationKey: string;
};
