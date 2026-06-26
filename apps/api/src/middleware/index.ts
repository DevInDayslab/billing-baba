import type { FastifyInstance } from 'fastify';
import { registerAuthMiddleware } from './auth.middleware';
import { registerErrorMiddleware } from './error.middleware';
import { registerRequestLoggingMiddleware } from './request-logging.middleware';

export async function registerMiddleware(app: FastifyInstance): Promise<void> {
  await registerRequestLoggingMiddleware(app);
  await registerAuthMiddleware(app);
  await registerErrorMiddleware(app);
}
