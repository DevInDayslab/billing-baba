import swagger from '@fastify/swagger';
import type { FastifyInstance } from 'fastify';
import type { AppConfig } from '../config/app_config';

export async function registerSwaggerPlugin(
  app: FastifyInstance,
  config: AppConfig,
): Promise<void> {
  await app.register(swagger, {
    openapi: {
      info: {
        title: config.appName,
        version: config.version,
      },
    },
  });
}
