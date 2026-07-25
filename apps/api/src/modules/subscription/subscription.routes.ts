import type { FastifyPluginAsync, FastifyRequest } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createSubscriptionController } from './subscription.controller';

type RequestWithRawBody = FastifyRequest & { rawBody?: Buffer };

export const createSubscriptionRoutes = (
  config: AppConfig,
): FastifyPluginAsync => {
  const controller = createSubscriptionController(config);

  return async (app) => {
    app.addHook('preParsing', async (request, _reply, payload) => {
      if (!request.url.includes('/webhook')) {
        return payload;
      }

      const chunks: Buffer[] = [];
      for await (const chunk of payload) {
        chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk));
      }
      const rawBody = Buffer.concat(chunks);
      (request as RequestWithRawBody).rawBody = rawBody;
      return rawBody;
    });

    app.post('/webhook', controller.webhook);

    const preHandler = [authenticate, requireBusiness];
    app.get('/plans', { preHandler }, controller.getPlans);
    app.get('/current', { preHandler }, controller.getCurrent);
    app.get('/history', { preHandler }, controller.getHistory);
    app.post('/create-order', { preHandler }, controller.createOrder);
    app.post('/verify', { preHandler }, controller.verify);
    app.post('/refresh', { preHandler }, controller.refresh);
  };
};
