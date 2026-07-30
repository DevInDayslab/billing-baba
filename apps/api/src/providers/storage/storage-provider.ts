import type {
  CopyObjectParams,
  CreateDownloadUrlParams,
  CreateDownloadUrlResult,
  CreateUploadUrlParams,
  CreateUploadUrlResult,
  HeadObjectResult,
  MoveObjectParams,
  GetObjectResult,
  PutObjectParams,
  PutObjectResult,
} from './storage.types';

/**
 * Provider-agnostic object storage interface.
 * Business modules must never call S3 (or any vendor SDK) directly.
 */
export interface StorageProvider {
  readonly name: string;
  readonly bucket: string;

  createUploadUrl(
    params: CreateUploadUrlParams,
  ): Promise<CreateUploadUrlResult>;

  createDownloadUrl(
    params: CreateDownloadUrlParams,
  ): Promise<CreateDownloadUrlResult>;

  delete(key: string): Promise<void>;

  head(key: string): Promise<HeadObjectResult>;

  exists(key: string): Promise<boolean>;

  copy(params: CopyObjectParams): Promise<void>;

  move(params: MoveObjectParams): Promise<void>;

  getObject(key: string): Promise<GetObjectResult>;

  putObject(params: PutObjectParams): Promise<PutObjectResult>;
}
