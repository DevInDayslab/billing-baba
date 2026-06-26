import type { FastifyInstance } from 'fastify';
import type { AppConfig } from '../config/app_config';
import { registerCorsPlugin } from './cors.plugin';
import { registerRateLimitPlugin } from './rate-limit.plugin';
import { registerSensiblePlugin } from './sensible.plugin';
import { registerSwaggerPlugin } from './swagger.plugin';
import { registerSwaggerUiPlugin } from './swagger-ui.plugin';

export async function registerPlugins(
  app: FastifyInstance,
  config: AppConfig,
): Promise<void> {
  await registerSensiblePlugin(app);
  await registerCorsPlugin(app);
  await registerRateLimitPlugin(app);
  await registerSwaggerPlugin(app, config);
  await registerSwaggerUiPlugin(app);

  // TODO: Register JWT when authentication is implemented.
}
