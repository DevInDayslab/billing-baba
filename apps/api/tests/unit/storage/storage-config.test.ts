import { afterEach, describe, expect, test } from 'bun:test';
import {
  assertStorageConfig,
  loadAppConfig,
} from '../../../src/config/app_config';

const REQUIRED = {
  APP_NAME: 'Billing Baba API',
  NODE_ENV: 'test',
  HOST: '0.0.0.0',
  PORT: '3000',
  API_PREFIX: '/api/v1',
  LOG_LEVEL: 'silent',
} as const;

function withEnv(
  overrides: Record<string, string | undefined>,
  fn: () => void,
) {
  const previous: Record<string, string | undefined> = {};
  const keys = new Set([
    ...Object.keys(overrides),
    ...Object.keys(REQUIRED),
    'S3_ENDPOINT',
    'S3_BUCKET',
    'S3_ACCESS_KEY_ID',
    'S3_SECRET_ACCESS_KEY',
    'S3_REGION',
    'S3_PUBLIC_BASE_URL',
    'S3_PUBLIC_ENDPOINT',
    'NOTIFICATION_PROVIDER',
    'TWILIO_ACCOUNT_SID',
    'TWILIO_AUTH_TOKEN',
    'TWILIO_PHONE_NUMBER',
  ]);

  for (const key of keys) {
    previous[key] = process.env[key];
  }

  for (const [key, value] of Object.entries(REQUIRED)) {
    if (!(key in overrides)) {
      process.env[key] = value;
    }
  }

  for (const key of [
    'S3_ENDPOINT',
    'S3_BUCKET',
    'S3_ACCESS_KEY_ID',
    'S3_SECRET_ACCESS_KEY',
    'S3_REGION',
    'S3_PUBLIC_BASE_URL',
    'S3_PUBLIC_ENDPOINT',
  ]) {
    if (!(key in overrides)) {
      delete process.env[key];
    }
  }

  for (const [key, value] of Object.entries(overrides)) {
    if (value === undefined) {
      delete process.env[key];
    } else {
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

describe('loadAppConfig storage validation', () => {
  afterEach(() => {
    // ensure no leakage from other suites relying on empty S3
  });

  test('empty S3 config disables storage', () => {
    withEnv({}, () => {
      const config = loadAppConfig();
      expect(config.storageConfigured).toBe(false);
    });
  });

  test('complete S3 config enables storage', () => {
    withEnv(
      {
        S3_ENDPOINT: 'https://s3.example.com',
        S3_BUCKET: 'bucket',
        S3_ACCESS_KEY_ID: 'ak',
        S3_SECRET_ACCESS_KEY: 'sk',
      },
      () => {
        const config = loadAppConfig();
        expect(config.storageConfigured).toBe(true);
        expect(config.s3Bucket).toBe('bucket');
        expect(config.storageMaxFileBytes).toBe(10_485_760);
      },
    );
  });

  test('S3_PUBLIC_ENDPOINT is loaded when set', () => {
    withEnv(
      {
        S3_ENDPOINT: 'https://internal.s3.example.com',
        S3_BUCKET: 'bucket',
        S3_ACCESS_KEY_ID: 'ak',
        S3_SECRET_ACCESS_KEY: 'sk',
        S3_PUBLIC_ENDPOINT: 'https://public.s3.example.com',
      },
      () => {
        const config = loadAppConfig();
        expect(config.s3PublicEndpoint).toBe('https://public.s3.example.com');
      },
    );
  });

  test('partial S3 config fails fast', () => {
    withEnv(
      {
        S3_ENDPOINT: 'https://s3.example.com',
        S3_BUCKET: 'bucket',
      },
      () => {
        expect(() => loadAppConfig()).toThrow(/Partial S3 configuration/);
      },
    );
  });

  test('assertStorageConfig returns false when empty', () => {
    expect(
      assertStorageConfig({
        S3_ENDPOINT: undefined,
        S3_BUCKET: undefined,
        S3_ACCESS_KEY_ID: undefined,
        S3_SECRET_ACCESS_KEY: undefined,
      } as never),
    ).toBe(false);
  });
});
