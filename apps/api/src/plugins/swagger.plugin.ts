import swagger from '@fastify/swagger';
import type { FastifyInstance } from 'fastify';
import type { OpenAPIV3 } from 'openapi-types';
import type { AppConfig } from '../config/app_config';
import { buildOpenApiDocument } from '../openapi/document';

export async function registerSwaggerPlugin(
  app: FastifyInstance,
  config: AppConfig,
): Promise<void> {
  const document = buildOpenApiDocument(config);

  // Static mode serves only our curated spec — prevents duplicate paths from
  // Fastify route introspection (/path vs /path/) and untagged "default" entries.
  await app.register(swagger, {
    mode: 'static',
    specification: {
      document: document as unknown as OpenAPIV3.Document,
    },
  });
}
