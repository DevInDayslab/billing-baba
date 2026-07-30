import type { AppConfig } from '../../config/app_config';
import {
  createGeneratedDocumentRoutes,
  createPublicGeneratedDocumentRoutes,
} from './generated-document.routes';

export function generatedDocumentsModule(config: AppConfig) {
  return createGeneratedDocumentRoutes(config);
}

export function publicGeneratedDocumentsModule(config: AppConfig) {
  return createPublicGeneratedDocumentRoutes(config);
}
