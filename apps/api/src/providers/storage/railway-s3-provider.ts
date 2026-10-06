import {
  CopyObjectCommand,
  DeleteObjectCommand,
  GetObjectCommand,
  HeadObjectCommand,
  PutObjectCommand,
  S3Client,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import type {
  CopyObjectParams,
  CreateDownloadUrlParams,
  CreateDownloadUrlResult,
  CreateUploadUrlParams,
  CreateUploadUrlResult,
  GetObjectResult,
  HeadObjectResult,
  MoveObjectParams,
  PutObjectParams,
  PutObjectResult,
} from './storage.types';
import type { StorageProvider } from './storage-provider';

export type RailwayS3ProviderConfig = {
  endpoint: string;
  bucket: string;
  region: string;
  accessKeyId: string;
  secretAccessKey: string;
  forcePathStyle: boolean;
  ssl: boolean;
  /**
   * Optional publicly reachable endpoint for presigned PUT/GET URLs.
   * When set, clients receive signed URLs against this host while the API
   * continues to use `endpoint` for head/put/delete/copy.
   */
  publicEndpoint?: string;
};

export function normalizeEndpoint(endpoint: string, ssl: boolean): string {
  const trimmed = endpoint.trim().replace(/\/$/, '');
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  return `${ssl ? 'https' : 'http'}://${trimmed}`;
}

function createS3Client(params: {
  endpoint: string;
  region: string;
  accessKeyId: string;
  secretAccessKey: string;
  forcePathStyle: boolean;
  ssl: boolean;
}): S3Client {
  return new S3Client({
    region: params.region,
    endpoint: normalizeEndpoint(params.endpoint, params.ssl),
    forcePathStyle: params.forcePathStyle,
    credentials: {
      accessKeyId: params.accessKeyId,
      secretAccessKey: params.secretAccessKey,
    },
  });
}

export class RailwayS3Provider implements StorageProvider {
  readonly name = 'railway_s3';
  readonly bucket: string;

  /** Server-side operations (head, put, delete, copy). */
  private readonly client: S3Client;
  /** Client-facing signed URLs — may use a public endpoint. */
  private readonly signingClient: S3Client;

  constructor(config: RailwayS3ProviderConfig) {
    this.bucket = config.bucket;
    this.client = createS3Client({
      endpoint: config.endpoint,
      region: config.region,
      accessKeyId: config.accessKeyId,
      secretAccessKey: config.secretAccessKey,
      forcePathStyle: config.forcePathStyle,
      ssl: config.ssl,
    });
    const signingEndpoint = config.publicEndpoint?.trim() || config.endpoint;
    this.signingClient =
      signingEndpoint === config.endpoint
        ? this.client
        : createS3Client({
            endpoint: signingEndpoint,
            region: config.region,
            accessKeyId: config.accessKeyId,
            secretAccessKey: config.secretAccessKey,
            forcePathStyle: config.forcePathStyle,
            ssl: config.ssl,
          });
  }

  async createUploadUrl(
    params: CreateUploadUrlParams,
  ): Promise<CreateUploadUrlResult> {
    const command = new PutObjectCommand({
      Bucket: this.bucket,
      Key: params.key,
      ContentType: params.mimeType,
      ...(params.contentLength !== undefined
        ? { ContentLength: params.contentLength }
        : {}),
    });

    const url = await getSignedUrl(this.signingClient, command, {
      expiresIn: params.expiresInSeconds,
    });

    const expiresAt = new Date(Date.now() + params.expiresInSeconds * 1000);

    return {
      url,
      headers: {
        'Content-Type': params.mimeType,
        ...(params.contentLength !== undefined
          ? { 'Content-Length': String(params.contentLength) }
          : {}),
      },
      expiresAt,
    };
  }

  async createDownloadUrl(
    params: CreateDownloadUrlParams,
  ): Promise<CreateDownloadUrlResult> {
    const command = new GetObjectCommand({
      Bucket: this.bucket,
      Key: params.key,
    });

    const url = await getSignedUrl(this.signingClient, command, {
      expiresIn: params.expiresInSeconds,
    });

    return {
      url,
      expiresAt: new Date(Date.now() + params.expiresInSeconds * 1000),
    };
  }

  async delete(key: string): Promise<void> {
    await this.client.send(
      new DeleteObjectCommand({
        Bucket: this.bucket,
        Key: key,
      }),
    );
  }

  async head(key: string): Promise<HeadObjectResult> {
    try {
      const result = await this.client.send(
        new HeadObjectCommand({
          Bucket: this.bucket,
          Key: key,
        }),
      );

      return {
        exists: true,
        contentType: result.ContentType,
        contentLength: result.ContentLength,
        etag: result.ETag?.replaceAll('"', ''),
        lastModified: result.LastModified,
      };
    } catch (error) {
      if (isNotFoundError(error)) {
        return { exists: false };
      }
      throw error;
    }
  }

  async exists(key: string): Promise<boolean> {
    const result = await this.head(key);
    return result.exists;
  }

  async copy(params: CopyObjectParams): Promise<void> {
    await this.client.send(
      new CopyObjectCommand({
        Bucket: this.bucket,
        CopySource: `${this.bucket}/${params.sourceKey}`,
        Key: params.destinationKey,
      }),
    );
  }

  async move(params: MoveObjectParams): Promise<void> {
    await this.copy(params);
    await this.delete(params.sourceKey);
  }

  async getObject(key: string): Promise<GetObjectResult> {
    const result = await this.client.send(
      new GetObjectCommand({
        Bucket: this.bucket,
        Key: key,
      }),
    );

    const bytes = await streamToBuffer(result.Body);
    return {
      body: bytes,
      contentType: result.ContentType,
      contentLength: result.ContentLength ?? bytes.length,
      etag: result.ETag?.replaceAll('"', ''),
    };
  }

  async putObject(params: PutObjectParams): Promise<PutObjectResult> {
    const body = Buffer.isBuffer(params.body)
      ? params.body
      : Buffer.from(params.body);
    const result = await this.client.send(
      new PutObjectCommand({
        Bucket: this.bucket,
        Key: params.key,
        Body: body,
        ContentType: params.mimeType,
        ContentLength: body.length,
      }),
    );

    return {
      etag: result.ETag?.replaceAll('"', ''),
      contentLength: body.length,
    };
  }
}

async function streamToBuffer(body: unknown): Promise<Buffer> {
  if (!body) {
    return Buffer.alloc(0);
  }
  if (Buffer.isBuffer(body)) {
    return body;
  }
  if (body instanceof Uint8Array) {
    return Buffer.from(body);
  }
  if (
    typeof body === 'object' &&
    body !== null &&
    Symbol.asyncIterator in body
  ) {
    const chunks: Buffer[] = [];
    for await (const chunk of body as AsyncIterable<Uint8Array | string>) {
      chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk));
    }
    return Buffer.concat(chunks);
  }
  if (
    typeof body === 'object' &&
    body !== null &&
    'transformToByteArray' in body
  ) {
    const bytes = await (
      body as { transformToByteArray: () => Promise<Uint8Array> }
    ).transformToByteArray();
    return Buffer.from(bytes);
  }
  throw new Error('Unsupported S3 object body type');
}

function isNotFoundError(error: unknown): boolean {
  if (!error || typeof error !== 'object') return false;
  const name = 'name' in error ? String(error.name) : '';
  const metadata =
    '$metadata' in error &&
    error.$metadata &&
    typeof error.$metadata === 'object'
      ? (error.$metadata as { httpStatusCode?: number })
      : undefined;
  return (
    name === 'NotFound' ||
    name === 'NoSuchKey' ||
    name === 'NotFoundError' ||
    metadata?.httpStatusCode === 404
  );
}
