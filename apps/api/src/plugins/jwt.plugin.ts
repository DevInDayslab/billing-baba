import jwt from '@fastify/jwt';
import type { FastifyInstance } from 'fastify';
import type { AppConfig } from '../config/app_config';

export async function registerJwtPlugin(
  app: FastifyInstance,
  config: AppConfig,
): Promise<void> {
  if (!config.jwtSecret) {
    app.log.warn(
      'JWT_SECRET is not set — JWT plugin skipped. Set JWT_SECRET before implementing authentication.',
    );
    return;
  }

  await app.register(jwt, {
    secret: config.jwtSecret,
  });

  // TODO: Implement login and access token generation.
  // TODO: Implement refresh token flow using JWT_REFRESH_SECRET.
  // TODO: Add authentication middleware to protect routes.
  // TODO: Attach userId and businessId to request context for logging.
}
