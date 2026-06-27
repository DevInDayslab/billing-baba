import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { checkDatabaseHealth } from '../../db';
import type { ApiSuccessResponse } from '../../shared/types';

const startTime = Date.now();

type HealthData = {
  status: 'ok';
  name: string;
  version: string;
  environment: string;
  uptime: number;
  timestamp: string;
};

type DatabaseHealthData = {
  database: 'connected' | 'disconnected' | 'not_configured';
};

function buildHealthData(config: AppConfig): HealthData {
  return {
    status: 'ok',
    name: config.appName,
    version: config.version,
    environment: config.environment,
    uptime: Math.floor((Date.now() - startTime) / 1000),
    timestamp: new Date().toISOString(),
  };
}

export function createHealthModule(config: AppConfig): FastifyPluginAsync {
  return async (app) => {
    const healthHandler = async (): Promise<
      ApiSuccessResponse<HealthData>
    > => ({
      success: true,
      data: buildHealthData(config),
    });

    app.get('/health', healthHandler);
    app.get('/ready', healthHandler);

    app.get('/health/db', async (_request, reply) => {
      const database = await checkDatabaseHealth();
      const statusCode = database === 'disconnected' ? 503 : 200;

      const response: ApiSuccessResponse<DatabaseHealthData> = {
        success: true,
        data: { database },
      };

      return reply.status(statusCode).send(response);
    });
  };
}
