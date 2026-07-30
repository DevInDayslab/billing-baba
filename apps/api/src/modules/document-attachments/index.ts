import type { AppConfig } from '../../config/app_config';
import { createDocumentAttachmentRoutes } from './document-attachment.routes';

export function documentAttachmentsModule(config: AppConfig) {
  return createDocumentAttachmentRoutes(config);
}
