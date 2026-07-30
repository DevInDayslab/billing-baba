import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { checkDatabaseHealth } from '../../db';
import { sendData } from '../../shared/http/response';
import type { ApiDataResponse } from '../../shared/types';

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
    const healthHandler = async (): Promise<ApiDataResponse<HealthData>> => ({
      data: buildHealthData(config),
    });

    app.get('/health', async (_request, reply) => {
      const payload = await healthHandler();
      return sendData(reply, payload.data);
    });
    app.get('/ready', async (_request, reply) => {
      const payload = await healthHandler();
      return sendData(reply, payload.data);
    });

    app.get('/health/db', async (_request, reply) => {
      const database = await checkDatabaseHealth();
      const statusCode = database === 'disconnected' ? 503 : 200;
      const data: DatabaseHealthData = { database };
      return sendData(reply, data, statusCode);
    });
  };
}
