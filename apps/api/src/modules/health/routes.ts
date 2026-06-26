import type { FastifyInstance } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { checkDatabaseConnection } from '../../db';

const startTime = Date.now();

function buildHealthResponse(config: AppConfig) {
  return {
    status: 'ok' as const,
    name: config.appName,
    version: config.version,
    environment: config.environment,
    uptime: Math.floor((Date.now() - startTime) / 1000),
    timestamp: new Date().toISOString(),
  };
}

export async function registerHealthRoutes(
  app: FastifyInstance,
  config: AppConfig,
): Promise<void> {
  const healthHandler = async () => buildHealthResponse(config);

  app.get('/', healthHandler);
  app.get('/health', healthHandler);
  app.get('/ready', healthHandler);

  app.get('/health/db', async (_request, reply) => {
    const connected = await checkDatabaseConnection();

    return reply.status(connected ? 200 : 503).send({
      database: connected ? 'connected' : 'disconnected',
    });
  });
}
