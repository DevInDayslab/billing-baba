import crypto from 'node:crypto';
import Fastify, { type FastifyInstance } from 'fastify';
import type { AppConfig } from './config/app_config';
import { createLoggerOptions } from './config/logger';
import { registerMiddleware } from './middleware';
import { registerModules } from './modules';
import { registerPlugins } from './plugins';

function createRequestId(): string {
  return `req-${crypto.randomUUID()}`;
}

export async function buildApp(config: AppConfig): Promise<FastifyInstance> {
  const app = Fastify({
    logger: createLoggerOptions(config),
    disableRequestLogging: true,
    genReqId: createRequestId,
    requestIdHeader: 'x-request-id',
    requestIdLogLabel: 'requestId',
  });

  await registerPlugins(app, config);
  await registerMiddleware(app);
  await registerModules(app, config);

  return app;
}
