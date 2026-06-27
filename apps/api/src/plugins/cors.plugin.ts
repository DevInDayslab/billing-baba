import cors from '@fastify/cors';
import type { FastifyInstance } from 'fastify';
import type { AppConfig } from '../config/app_config';

const DEVELOPMENT_ORIGINS = [
  'http://localhost:3000',
  'http://127.0.0.1:3000',
  'http://localhost:5173',
  'http://127.0.0.1:5173',
  'http://localhost:8080',
  'http://127.0.0.1:8080',
];

export async function registerCorsPlugin(
  app: FastifyInstance,
  config: AppConfig,
): Promise<void> {
  if (config.environment === 'development') {
    await app.register(cors, {
      origin: DEVELOPMENT_ORIGINS,
      credentials: true,
    });
    return;
  }

  await app.register(cors, {
    origin: config.corsOrigins.length > 0 ? config.corsOrigins : false,
    credentials: true,
  });
}
