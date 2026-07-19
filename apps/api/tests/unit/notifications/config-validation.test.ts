import { afterEach, describe, expect, test } from 'bun:test';
import { loadAppConfig } from '../../../src/config/app_config';

const REQUIRED = {
  APP_NAME: 'Billing Baba API',
  NODE_ENV: 'test',
  HOST: '0.0.0.0',
  PORT: '3000',
  API_PREFIX: '/api/v1',
  LOG_LEVEL: 'silent',
} as const;

function withEnv(overrides: Record<string, string | undefined>, fn: () => void) {
  const previous: Record<string, string | undefined> = {};
  for (const key of Object.keys(overrides)) {
    previous[key] = process.env[key];
    const value = overrides[key];
    if (value === undefined) {
      delete process.env[key];
    } else {
      process.env[key] = value;
    }
  }
  for (const [key, value] of Object.entries(REQUIRED)) {
    if (!(key in overrides)) {
      previous[key] = process.env[key];
      process.env[key] = value;
    }
  }
  try {
    fn();
  } finally {
    for (const [key, value] of Object.entries(previous)) {
      if (value === undefined) delete process.env[key];
      else process.env[key] = value;
    }
  }
}

describe('loadAppConfig notification validation', () => {
  afterEach(() => {
    // no-op; each test restores env
  });

  test('allows console provider without Twilio credentials', () => {
    withEnv(
      {
        NOTIFICATION_PROVIDER: 'console',
        TWILIO_ACCOUNT_SID: undefined,
        TWILIO_AUTH_TOKEN: undefined,
        TWILIO_PHONE_NUMBER: undefined,
        WEBSITE_URL: undefined,
      },
      () => {
        const config = loadAppConfig();
        expect(config.notificationProvider).toBe('console');
      },
    );
  });

  test('fails fast when twilio selected without credentials', () => {
    withEnv(
      {
        NOTIFICATION_PROVIDER: 'twilio',
        TWILIO_ACCOUNT_SID: undefined,
        TWILIO_AUTH_TOKEN: undefined,
        TWILIO_PHONE_NUMBER: undefined,
        WEBSITE_URL: 'https://billingbaba.com',
      },
      () => {
        expect(() => loadAppConfig()).toThrow(/TWILIO_ACCOUNT_SID/);
      },
    );
  });

  test('fails fast when twilio selected without WEBSITE_URL', () => {
    withEnv(
      {
        NOTIFICATION_PROVIDER: 'twilio',
        TWILIO_ACCOUNT_SID: 'ACxxx',
        TWILIO_AUTH_TOKEN: 'secret',
        TWILIO_PHONE_NUMBER: '+14155238886',
        WEBSITE_URL: undefined,
      },
      () => {
        expect(() => loadAppConfig()).toThrow(/WEBSITE_URL/);
      },
    );
  });

  test('loads twilio when fully configured', () => {
    withEnv(
      {
        NOTIFICATION_PROVIDER: 'twilio',
        TWILIO_ACCOUNT_SID: 'ACxxx',
        TWILIO_AUTH_TOKEN: 'secret',
        TWILIO_PHONE_NUMBER: '+14155238886',
        WEBSITE_URL: 'https://billingbaba.com',
      },
      () => {
        const config = loadAppConfig();
        expect(config.notificationProvider).toBe('twilio');
        expect(config.twilioAccountSid).toBe('ACxxx');
      },
    );
  });
});
