import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createBarcodeLookupController } from './barcode-lookup.controller';

export const createBarcodeLookupRoutes = (): FastifyPluginAsync => {
  const controller = createBarcodeLookupController();

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.post(
      '/lookup',
      {
        preHandler,
        schema: {
          tags: ['Inventory'],
          summary: 'Barcode Gemini Lookup',
          body: {
            type: 'object',
            required: ['barcode'],
            properties: {
              barcode: { type: 'string', minLength: 1, maxLength: 50 },
            },
          },
        },
      },
      controller.lookup,
    );
  };
};
