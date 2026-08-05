import path from 'node:path';
import { config as loadEnv } from 'dotenv';
import { buildApp } from './app';
import { loadAppConfig } from './config/app_config';
import { resolveGeminiModel } from './modules/purchases/purchase-document-gemini.parser';
import { startPaymentReconciliationWorker } from './modules/payment-gateway/payment-reconciliation.worker';
import { startSubscriptionScheduler } from './modules/subscription/subscription.scheduler';
import {
  auditGeminiAuthEnvironment,
  describeGeminiKeyForLog,
  formatGeminiAuthEnvironmentLogLine,
  formatGeminiKeyLogLine,
} from './shared/gemini/gemini-client';
import { setupGracefulShutdown } from './shutdown';

loadEnv({ path: path.resolve(__dirname, '../.env'), override: true });

async function startServer(): Promise<void> {
  const config = loadAppConfig();
  const app = await buildApp(config);

  setupGracefulShutdown(app);

  await app.listen({ host: config.host, port: config.port });

  startSubscriptionScheduler(app, config);
  startPaymentReconciliationWorker(app, config);

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

  const geminiAuthEnv = auditGeminiAuthEnvironment();
  app.log.info(formatGeminiAuthEnvironmentLogLine(geminiAuthEnv));
  if (geminiAuthEnv.conflictingEnvVars.length > 0) {
    app.log.warn(
      `Gemini auth env vars present (unused when GEMINI_API_KEY is set, but verify they are not rewriting outbound requests): ${geminiAuthEnv.conflictingEnvVars.join(', ')}`,
    );
  }

  const geminiKey = describeGeminiKeyForLog();
  if (config.environment === 'development') {
    app.log.debug(formatGeminiKeyLogLine(geminiKey));
  } else {
    app.log.info(formatGeminiKeyLogLine(geminiKey));
  }

  if (geminiKey.issue) {
    if (config.environment === 'development') {
      app.log.debug(geminiKey.issue);
    } else {
      app.log.warn(geminiKey.issue);
    }
  }

  if (geminiKey.loadedSuccessfully) {
    app.log.info(
      `Purchase document parsing: Gemini Developer API, model ${resolveGeminiModel()}`,
    );
  } else if (process.env.ENABLE_MOCK_PURCHASE_PARSE === 'true') {
    app.log.info(
      'Purchase document parsing: mock mode (ENABLE_MOCK_PURCHASE_PARSE=true)',
    );
  } else if (config.environment === 'development') {
    app.log.debug(
      'Purchase document parsing disabled locally — set GEMINI_API_KEY or ENABLE_MOCK_PURCHASE_PARSE=true in apps/api/.env',
    );
  } else {
    app.log.warn(
      'POST /purchases/parse-document will return 503 until GEMINI_API_KEY is set in apps/api/.env (or Railway variables in production).',
    );
  }
}

startServer().catch((error: unknown) => {
  const message =
    error instanceof Error ? error.message : 'Unknown startup error';
  console.error(`Failed to start server:\n${message}`);
  process.exit(1);
});
