import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { createImagesModule } from '../images';
import { createStorageRoutes } from './storage.routes';

export function createStorageModule(config: AppConfig): FastifyPluginAsync {
  return async (app) => {
    await app.register(createStorageRoutes(config));
    await app.register(createImagesModule(config), { prefix: '/images' });
  };
}

export {
  ALLOWED_STORAGE_MIME_TYPES,
  STORAGE_PURPOSES,
  STORAGE_VISIBILITIES,
} from './storage.constants';
export { StorageService } from './storage.service';
export type {
  DownloadResult,
  StorageAsset,
  UploadIntent,
} from './storage.types';
export { buildStoragePath } from './storage-path.builder';
