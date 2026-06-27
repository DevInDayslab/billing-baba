import { z } from 'zod';

const emptyToUndefined = (value: unknown) =>
  value === '' || value === undefined ? undefined : value;

const envSchema = z.object({
  APP_NAME: z.string().min(1, 'APP_NAME is required'),
  NODE_ENV: z.enum(['development', 'production', 'test'], {
    message: 'NODE_ENV must be development, production, or test',
  }),
  HOST: z.string().min(1, 'HOST is required'),
  PORT: z.coerce
    .number({ message: 'PORT must be a number' })
    .int()
    .positive('PORT must be a positive integer'),
  API_PREFIX: z
    .string()
    .min(1, 'API_PREFIX is required')
    .refine((value) => value.startsWith('/'), {
      message: 'API_PREFIX must start with /',
    }),
  LOG_LEVEL: z.enum(
    ['fatal', 'error', 'warn', 'info', 'debug', 'trace', 'silent'],
    { message: 'LOG_LEVEL is invalid' },
  ),
  DATABASE_URL: z.preprocess(
    emptyToUndefined,
    z.string().url('DATABASE_URL must be a valid URL').optional(),
  ),
  JWT_SECRET: z.preprocess(emptyToUndefined, z.string().min(1).optional()),
  JWT_REFRESH_SECRET: z.preprocess(
    emptyToUndefined,
    z.string().min(1).optional(),
  ),
  CORS_ORIGINS: z.preprocess(emptyToUndefined, z.string().optional()),
  APP_VERSION: z.preprocess(emptyToUndefined, z.string().optional()),
});

export type AppConfig = {
  appName: string;
  version: string;
  host: string;
  port: number;
  apiPrefix: string;
  environment: 'development' | 'production' | 'test';
  logLevel: string;
  databaseUrl?: string;
  jwtSecret?: string;
  jwtRefreshSecret?: string;
  corsOrigins: string[];
};

export function loadAppConfig(): AppConfig {
  const result = envSchema.safeParse(process.env);

  if (!result.success) {
    const details = result.error.issues
      .map((issue) => `  - ${issue.path.join('.')}: ${issue.message}`)
      .join('\n');

    throw new Error(`Invalid environment configuration:\n${details}`);
  }

  const env = result.data;

  return {
    appName: env.APP_NAME,
    version: env.APP_VERSION ?? process.env.npm_package_version ?? '0.0.0',
    host: env.HOST,
    port: env.PORT,
    apiPrefix: env.API_PREFIX,
    environment: env.NODE_ENV,
    logLevel: env.LOG_LEVEL,
    databaseUrl: env.DATABASE_URL,
    jwtSecret: env.JWT_SECRET,
    jwtRefreshSecret: env.JWT_REFRESH_SECRET,
    corsOrigins:
      env.CORS_ORIGINS?.split(',')
        .map((origin) => origin.trim())
        .filter(Boolean) ?? [],
  };
}
