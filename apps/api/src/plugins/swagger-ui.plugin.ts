import swaggerUi from '@fastify/swagger-ui';
import type { FastifyInstance } from 'fastify';

export async function registerSwaggerUiPlugin(
  app: FastifyInstance,
): Promise<void> {
  await app.register(swaggerUi, {
    routePrefix: '/docs',
  });
}
