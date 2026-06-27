import 'dotenv/config';
import { buildApp } from './app';
import { loadAppConfig } from './config/app_config';
import { setupGracefulShutdown } from './shutdown';

async function startServer(): Promise<void> {
  const config = loadAppConfig();
  const app = await buildApp(config);

  setupGracefulShutdown(app);

  await app.listen({ host: config.host, port: config.port });

  app.log.info(
    `${config.appName} v${config.version} listening on http://${config.host}:${config.port}`,
  );
  app.log.info(`Environment: ${config.environment}`);
  app.log.info(`API prefix: ${config.apiPrefix}`);

  if (!config.databaseUrl) {
    app.log.warn(
      'DATABASE_URL is not set — database features are disabled until Neon is configured.',
    );
  }
}

startServer().catch((error: unknown) => {
  const message =
    error instanceof Error ? error.message : 'Unknown startup error';
  console.error(`Failed to start server:\n${message}`);
  process.exit(1);
});
