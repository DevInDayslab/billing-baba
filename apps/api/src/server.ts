import 'dotenv/config';
import { buildApp } from './app';
import { loadAppConfig } from './config/app_config';

async function startServer(): Promise<void> {
  const config = loadAppConfig();
  const app = await buildApp(config);

  await app.listen({ host: config.host, port: config.port });

  app.log.info(
    `${config.appName} v${config.version} listening on http://${config.host}:${config.port}`,
  );
  app.log.info(`Environment: ${config.environment}`);

  const shutdown = async (signal: string) => {
    app.log.info(`Received ${signal}, shutting down gracefully`);
    await app.close();
    process.exit(0);
  };

  process.on('SIGINT', () => {
    void shutdown('SIGINT');
  });

  process.on('SIGTERM', () => {
    void shutdown('SIGTERM');
  });
}

startServer().catch((error: unknown) => {
  console.error('Failed to start server', error);
  process.exit(1);
});
