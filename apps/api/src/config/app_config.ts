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
  MSG91_AUTH_KEY: z.preprocess(emptyToUndefined, z.string().min(1).optional()),
  ENABLE_DEV_LOGIN: z.preprocess((value) => {
    if (value === '' || value === undefined) return false;
    if (typeof value === 'string') {
      return value.toLowerCase() === 'true';
    }
    return Boolean(value);
  }, z.boolean().default(false)),
  CORS_ORIGINS: z.preprocess(emptyToUndefined, z.string().optional()),
  APP_VERSION: z.preprocess(emptyToUndefined, z.string().optional()),
  WEBSITE_URL: z.preprocess(
    emptyToUndefined,
    z.string().url('WEBSITE_URL must be a valid URL').optional(),
  ),
  INVITATION_EXPIRY_DAYS: z.preprocess((value) => {
    if (value === '' || value === undefined) return 7;
    return Number(value);
  }, z.number().int().positive().default(7)),
  NOTIFICATION_PROVIDER: z.preprocess(
    emptyToUndefined,
    z.enum(['console', 'twilio']).optional(),
  ),
  TWILIO_ACCOUNT_SID: z.preprocess(
    emptyToUndefined,
    z.string().min(1).optional(),
  ),
  TWILIO_AUTH_TOKEN: z.preprocess(
    emptyToUndefined,
    z.string().min(1).optional(),
  ),
  TWILIO_PHONE_NUMBER: z.preprocess(
    emptyToUndefined,
    z.string().min(1).optional(),
  ),
  INVOICE_SHARE_EXPIRY_DAYS: z.preprocess((value) => {
    if (value === '' || value === undefined) return 90;
    return Number(value);
  }, z.number().int().positive().default(90)),
  NOTIFICATION_IDEMPOTENCY_TTL_HOURS: z.preprocess((value) => {
    if (value === '' || value === undefined) return 24;
    return Number(value);
  }, z.number().int().positive().default(24)),
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
  msg91AuthKey?: string;
  enableDevLogin: boolean;
  corsOrigins: string[];
  websiteUrl: string;
  invitationExpiryDays: number;
  notificationProvider: 'console' | 'twilio';
  twilioAccountSid?: string;
  twilioAuthToken?: string;
  twilioPhoneNumber?: string;
  invoiceShareExpiryDays: number;
  notificationIdempotencyTtlHours: number;
};

function assertTwilioConfig(env: z.infer<typeof envSchema>): void {
  if ((env.NOTIFICATION_PROVIDER ?? 'console') !== 'twilio') {
    return;
  }

  const missing: string[] = [];
  if (!env.TWILIO_ACCOUNT_SID) missing.push('TWILIO_ACCOUNT_SID');
  if (!env.TWILIO_AUTH_TOKEN) missing.push('TWILIO_AUTH_TOKEN');
  if (!env.TWILIO_PHONE_NUMBER) missing.push('TWILIO_PHONE_NUMBER');
  if (!env.WEBSITE_URL) missing.push('WEBSITE_URL');

  if (missing.length > 0) {
    throw new Error(
      `NOTIFICATION_PROVIDER=twilio requires: ${missing.join(', ')}. ` +
        'Set these environment variables or switch NOTIFICATION_PROVIDER to console.',
    );
  }
}

export function loadAppConfig(): AppConfig {
  const result = envSchema.safeParse(process.env);

  if (!result.success) {
    const details = result.error.issues
      .map((issue) => `  - ${issue.path.join('.')}: ${issue.message}`)
      .join('\n');

    throw new Error(`Invalid environment configuration:\n${details}`);
  }

  const env = result.data;
  assertTwilioConfig(env);

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
    msg91AuthKey: env.MSG91_AUTH_KEY,
    enableDevLogin: env.ENABLE_DEV_LOGIN,
    corsOrigins:
      env.CORS_ORIGINS?.split(',')
        .map((origin) => origin.trim())
        .filter(Boolean) ?? [],
    websiteUrl: env.WEBSITE_URL ?? 'https://billingbaba.com',
    invitationExpiryDays: env.INVITATION_EXPIRY_DAYS,
    notificationProvider: env.NOTIFICATION_PROVIDER ?? 'console',
    twilioAccountSid: env.TWILIO_ACCOUNT_SID,
    twilioAuthToken: env.TWILIO_AUTH_TOKEN,
    twilioPhoneNumber: env.TWILIO_PHONE_NUMBER,
    invoiceShareExpiryDays: env.INVOICE_SHARE_EXPIRY_DAYS,
    notificationIdempotencyTtlHours: env.NOTIFICATION_IDEMPOTENCY_TTL_HOURS,
  };
}
