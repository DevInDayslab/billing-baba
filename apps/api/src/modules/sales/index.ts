import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { createSalesInvoiceShareRoutes } from '../invoice-share';
import { createSaleFaRoutes } from './sale-fa.routes';
import {
  createDocumentSequenceRoutes,
  createPosSessionRoutes,
  createSalesDocumentRoutes,
} from './sales-document.routes';

export function createSalesModule(config: AppConfig): FastifyPluginAsync {
  return async (app) => {
    await app.register(createSalesDocumentRoutes(), {
      prefix: '/sales-documents',
    });
    await app.register(createSalesInvoiceShareRoutes(config), {
      prefix: '/sales-documents',
    });
    await app.register(createPosSessionRoutes(), { prefix: '/pos-sessions' });
    await app.register(createDocumentSequenceRoutes(), {
      prefix: '/document-sequences',
    });
    await app.register(createSaleFaRoutes(), {
      prefix: '/fixed-asset-sales',
    });
  };
}
