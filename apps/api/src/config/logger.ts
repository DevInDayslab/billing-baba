import type { FastifyError, FastifyServerOptions } from 'fastify';
import type { AppConfig } from './app_config';

const PRETTY_IGNORE =
  'pid,hostname,reqId,req,res,responseTime,req.hostname,req.remotePort,req.remoteAddress';

function createPrettyTransportOptions() {
  return {
    target: 'pino-pretty',
    options: {
      colorize: true,
      translateTime: "UTC:HH:MM:ss' UTC'",
      ignore: PRETTY_IGNORE,
      singleLine: false,
      levelFirst: true,
      // Avoid worker threads — required for Bun (especially on Windows).
      sync: true,
    },
  };
}

function createErrorSerializer(isDebug: boolean) {
  return (error: FastifyError) => {
    const serialized = {
      type: error.name,
      message: error.message,
      stack: error.stack ?? '',
      ...(error.validation !== undefined
        ? { validation: error.validation }
        : {}),
    };

    if (!isDebug) {
      return serialized;
    }

    return {
      ...serialized,
      ...Object.fromEntries(
        Object.entries(error).filter(([key]) => !(key in serialized)),
      ),
    };
  };
}

export function createLoggerOptions(
  config: AppConfig,
): FastifyServerOptions['logger'] {
  const isDebug = config.logLevel === 'debug' || config.logLevel === 'trace';
  const serializers = {
    err: createErrorSerializer(isDebug),
  };

  if (config.environment === 'development') {
    return {
      level: config.logLevel,
      transport: createPrettyTransportOptions(),
      serializers,
    };
  }

  return {
    level: config.logLevel,
    serializers,
  };
}
