import jwt from '@fastify/jwt';
import type { FastifyInstance } from 'fastify';
import type { AppConfig } from '../config/app_config';

const ACCESS_TOKEN_TTL = '15m';

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
    sign: {
      expiresIn: ACCESS_TOKEN_TTL,
    },
  });
}
