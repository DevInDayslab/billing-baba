import { createHash } from 'node:crypto';
import { mkdir, readFile, rm, stat, writeFile } from 'node:fs/promises';
import path from 'node:path';
import type { AppConfig } from '../../config/app_config';
import type { StorageProvider } from './storage-provider';
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

const DEV_BUCKET = 'local-dev';
const META_SUFFIX = '.meta.json';

type ObjectMeta = {
  contentType: string;
  contentLength: number;
  etag: string;
};

export type LocalFilesystemProviderConfig = {
  rootDir: string;
  apiBaseUrl: string;
};

function encodeStorageKey(key: string): string {
  return Buffer.from(key, 'utf8').toString('base64url');
}

export function decodeStorageKey(encoded: string): string {
  return Buffer.from(encoded, 'base64url').toString('utf8');
}

function resolveDevApiBase(config: AppConfig): string {
  const host = config.host === '0.0.0.0' ? '127.0.0.1' : config.host;
  return `http://${host}:${config.port}${config.apiPrefix}`;
}

export function createLocalFilesystemProvider(
  config: AppConfig,
): LocalFilesystemProvider {
  const rootDir = path.join(process.cwd(), '.local-storage');
  return new LocalFilesystemProvider({
    rootDir,
    apiBaseUrl: resolveDevApiBase(config),
  });
}

export class LocalFilesystemProvider implements StorageProvider {
  readonly name = 'local_filesystem';
  readonly bucket = DEV_BUCKET;

  private readonly rootDir: string;
  private readonly apiBaseUrl: string;

  constructor(config: LocalFilesystemProviderConfig) {
    this.rootDir = config.rootDir;
    this.apiBaseUrl = config.apiBaseUrl;
  }

  private objectPath(key: string): string {
    const normalized = path.normalize(key).replace(/^(\.\.(\/|\\|$))+/, '');
    return path.join(this.rootDir, this.bucket, normalized);
  }

  private metaPath(key: string): string {
    return `${this.objectPath(key)}${META_SUFFIX}`;
  }

  private objectUrl(key: string): string {
    return `${this.apiBaseUrl}/storage/_dev/objects/${encodeStorageKey(key)}`;
  }

  private async readMeta(key: string): Promise<ObjectMeta | null> {
    try {
      const raw = await readFile(this.metaPath(key), 'utf8');
      return JSON.parse(raw) as ObjectMeta;
    } catch {
      return null;
    }
  }

  private async writeMeta(key: string, meta: ObjectMeta): Promise<void> {
    const filePath = this.metaPath(key);
    await mkdir(path.dirname(filePath), { recursive: true });
    await writeFile(filePath, JSON.stringify(meta), 'utf8');
  }

  async createUploadUrl(
    params: CreateUploadUrlParams,
  ): Promise<CreateUploadUrlResult> {
    return {
      url: this.objectUrl(params.key),
      headers: {
        'Content-Type': params.mimeType,
      },
      expiresAt: new Date(Date.now() + params.expiresInSeconds * 1000),
    };
  }

  async createDownloadUrl(
    params: CreateDownloadUrlParams,
  ): Promise<CreateDownloadUrlResult> {
    return {
      url: this.objectUrl(params.key),
      expiresAt: new Date(Date.now() + params.expiresInSeconds * 1000),
    };
  }

  async delete(key: string): Promise<void> {
    await rm(this.objectPath(key), { force: true });
    await rm(this.metaPath(key), { force: true });
  }

  async head(key: string): Promise<HeadObjectResult> {
    try {
      const filePath = this.objectPath(key);
      const fileStat = await stat(filePath);
      const meta = await this.readMeta(key);
      return {
        exists: true,
        contentType: meta?.contentType,
        contentLength: meta?.contentLength ?? fileStat.size,
        etag: meta?.etag,
        lastModified: fileStat.mtime,
      };
    } catch {
      return { exists: false };
    }
  }

  async exists(key: string): Promise<boolean> {
    const result = await this.head(key);
    return result.exists;
  }

  async copy(params: CopyObjectParams): Promise<void> {
    const source = await this.getObject(params.sourceKey);
    await this.putObject({
      key: params.destinationKey,
      body: source.body,
      mimeType: source.contentType ?? 'application/octet-stream',
    });
  }

  async move(params: MoveObjectParams): Promise<void> {
    await this.copy(params);
    await this.delete(params.sourceKey);
  }

  async getObject(key: string): Promise<GetObjectResult> {
    const body = await readFile(this.objectPath(key));
    const meta = await this.readMeta(key);
    return {
      body,
      contentType: meta?.contentType,
      contentLength: meta?.contentLength ?? body.length,
      etag: meta?.etag,
    };
  }

  async putObject(params: PutObjectParams): Promise<PutObjectResult> {
    const body = Buffer.isBuffer(params.body)
      ? params.body
      : Buffer.from(params.body);
    const filePath = this.objectPath(params.key);
    await mkdir(path.dirname(filePath), { recursive: true });
    await writeFile(filePath, body);

    const etag = createHash('md5').update(body).digest('hex');
    const meta: ObjectMeta = {
      contentType: params.mimeType,
      contentLength: body.length,
      etag,
    };
    await this.writeMeta(params.key, meta);

    return {
      etag,
      contentLength: body.length,
    };
  }
}
