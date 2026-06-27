import type { FastifyBaseLogger, FastifyInstance } from 'fastify';
import { closeDatabase } from './db';

let isShuttingDown = false;

async function flushLogger(logger: FastifyBaseLogger): Promise<void> {
  return new Promise((resolve) => {
    const pinoLogger = logger as FastifyBaseLogger & {
      flush?: (callback: () => void) => void;
    };

    if (typeof pinoLogger.flush === 'function') {
      pinoLogger.flush(() => resolve());
      return;
    }

    resolve();
  });
}

export function setupGracefulShutdown(app: FastifyInstance): void {
  const shutdown = async (signal: string) => {
    if (isShuttingDown) {
      return;
    }

    isShuttingDown = true;

    try {
      app.log.info(`Received ${signal} — starting graceful shutdown`);

      app.log.info('Stopping acceptance of new requests');
      await app.close();
      app.log.info('Fastify server closed');

      app.log.info('Closing database connections');
      await closeDatabase();
      app.log.info('Database connections closed');

      app.log.info('Flushing logger');
      await flushLogger(app.log);
      app.log.info('Logger flushed');

      app.log.info('Shutdown complete');
      process.exit(0);
    } catch (error: unknown) {
      const message =
        error instanceof Error ? error.message : 'Unknown shutdown error';
      app.log.error(`Shutdown failed: ${message}`);
      process.exit(1);
    }
  };

  process.on('SIGINT', () => {
    void shutdown('SIGINT');
  });

  process.on('SIGTERM', () => {
    void shutdown('SIGTERM');
  });
}
