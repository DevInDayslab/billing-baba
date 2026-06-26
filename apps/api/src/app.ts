import Fastify, {
  type FastifyError,
  type FastifyInstance,
  type FastifyServerOptions,
} from 'fastify';
import type { AppConfig } from './config/app_config';
import { registerMiddleware } from './middleware';
import { registerHealthRoutes } from './modules/health/routes';
import { registerPlugins } from './plugins';
import { AppError } from './shared/errors';

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

function registerErrorHandler(app: FastifyInstance): void {
  app.setErrorHandler((error: FastifyError | AppError, request, reply) => {
    if (error instanceof AppError) {
      return reply.status(error.statusCode).send({
        error: {
          code: error.code,
          message: error.message,
        },
      });
    }

    request.log.error(error);

    const statusCode = error.statusCode ?? 500;
    const message =
      statusCode >= 500 ? 'An unexpected error occurred' : error.message;

    return reply.status(statusCode).send({
      error: {
        code: statusCode >= 500 ? 'INTERNAL_ERROR' : 'REQUEST_ERROR',
        message,
      },
    });
  });
}

async function registerRoutes(
  app: FastifyInstance,
  config: AppConfig,
): Promise<void> {
  await registerHealthRoutes(app, config);

  // TODO: Register feature module routes under config.apiPrefix.
}

export async function buildApp(config: AppConfig): Promise<FastifyInstance> {
  const app = Fastify({
    logger: createLoggerOptions(config),
  });

  await registerPlugins(app, config);
  await registerMiddleware(app);
  await registerRoutes(app, config);
  registerErrorHandler(app);

  return app;
}
