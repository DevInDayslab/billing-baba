import { z } from 'zod';

const envSchema = z.object({
  APP_NAME: z.string().min(1).default('Billing Baba API'),
  NODE_ENV: z
    .enum(['development', 'production', 'test'])
    .default('development'),
  HOST: z.string().min(1).default('0.0.0.0'),
  PORT: z.coerce.number().int().positive().default(3000),
  API_PREFIX: z.string().min(1).default('/api/v1'),
  LOG_LEVEL: z
    .enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace', 'silent'])
    .default('info'),
});

export type AppConfig = {
  appName: string;
  version: string;
  host: string;
  port: number;
  apiPrefix: string;
  environment: 'development' | 'production' | 'test';
  logLevel: string;
};

export function loadAppConfig(): AppConfig {
  const env = envSchema.parse(process.env);

  return {
    appName: env.APP_NAME,
    version:
      process.env.APP_VERSION ?? process.env.npm_package_version ?? '0.0.0',
    host: env.HOST,
    port: env.PORT,
    apiPrefix: env.API_PREFIX,
    environment: env.NODE_ENV,
    logLevel: env.LOG_LEVEL,
  };
}
