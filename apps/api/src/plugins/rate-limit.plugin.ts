import rateLimit from '@fastify/rate-limit';
import type { FastifyInstance } from 'fastify';
import type { AppConfig } from '../config/app_config';

export async function registerRateLimitPlugin(
  app: FastifyInstance,
  config: AppConfig,
): Promise<void> {
  // Sale finalize issues many requests (document, lines, payment). Skip in dev/test.
  if (config.environment !== 'production') {
    return;
  }

  await app.register(rateLimit, {
    max: 100,
    timeWindow: '1 minute',
  });
}
