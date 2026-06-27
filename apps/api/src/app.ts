import crypto from 'node:crypto';
import Fastify, {
  type FastifyInstance,
  type FastifyServerOptions,
} from 'fastify';
import type { AppConfig } from './config/app_config';
import { registerMiddleware } from './middleware';
import { registerModules } from './modules';
import { registerPlugins } from './plugins';

function createRequestId(): string {
  return `req-${crypto.randomUUID()}`;
}

function createLoggerOptions(
  config: AppConfig,
): FastifyServerOptions['logger'] {
  if (config.environment === 'development') {
    return {
      level: config.logLevel,
      transport: {
        target: 'pino-pretty',
        options: {
          translateTime: 'HH:MM:ss Z',
          ignore: 'pid,hostname',
        },
      },
    };
  }

  return {
    level: config.logLevel,
  };
}

export async function buildApp(config: AppConfig): Promise<FastifyInstance> {
  const app = Fastify({
    logger: createLoggerOptions(config),
    genReqId: createRequestId,
    requestIdHeader: 'x-request-id',
    requestIdLogLabel: 'requestId',
  });

  await registerPlugins(app, config);
  await registerMiddleware(app);
  await registerModules(app, config);

  return app;
}
