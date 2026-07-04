import swagger from '@fastify/swagger';
import type { FastifyInstance } from 'fastify';
import type { AppConfig } from '../config/app_config';
import { buildOpenApiDocument } from '../openapi/document';

export async function registerSwaggerPlugin(
  app: FastifyInstance,
  config: AppConfig,
): Promise<void> {
  const document = buildOpenApiDocument(config);

  await app.register(swagger, {
    openapi: document as Record<string, unknown>,
  });
}
