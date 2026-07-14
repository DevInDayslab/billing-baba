import type { FastifyInstance } from 'fastify';
import type { AppConfig } from '../config/app_config';
import { registerCorsPlugin } from './cors.plugin';
import { registerJwtPlugin } from './jwt.plugin';
import { registerSensiblePlugin } from './sensible.plugin';
import { registerSwaggerPlugin } from './swagger.plugin';
import { registerSwaggerUiPlugin } from './swagger-ui.plugin';

export async function registerPlugins(
  app: FastifyInstance,
  config: AppConfig,
): Promise<void> {
  await registerSensiblePlugin(app);
  await registerCorsPlugin(app, config);
  await registerJwtPlugin(app, config);
  await registerSwaggerPlugin(app, config);
  await registerSwaggerUiPlugin(app);
}
