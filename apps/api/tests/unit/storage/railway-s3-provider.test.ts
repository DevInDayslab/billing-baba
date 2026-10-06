import { describe, expect, test } from 'bun:test';
import {
  normalizeEndpoint,
  RailwayS3Provider,
} from '../../../src/providers/storage/railway-s3-provider';

describe('normalizeEndpoint', () => {
  test('adds https when scheme missing and ssl true', () => {
    expect(normalizeEndpoint('storage.example.com', true)).toBe(
      'https://storage.example.com',
    );
  });

  test('preserves explicit scheme', () => {
    expect(normalizeEndpoint('http://storage.example.com/', true)).toBe(
      'http://storage.example.com',
    );
  });
});

describe('RailwayS3Provider publicEndpoint', () => {
  test('presigned upload URL uses publicEndpoint when set', async () => {
    const provider = new RailwayS3Provider({
      endpoint: 'https://internal.s3.example.com',
      publicEndpoint: 'https://public.s3.example.com',
      bucket: 'billing-baba',
      region: 'auto',
      accessKeyId: 'test-key',
      secretAccessKey: 'test-secret',
      forcePathStyle: true,
      ssl: true,
    });

    const result = await provider.createUploadUrl({
      key: 'prod/businesses/biz/items/a.png',
      mimeType: 'image/png',
      expiresInSeconds: 900,
      contentLength: 1024,
    });

    expect(result.url).toContain('public.s3.example.com');
    expect(result.url).not.toContain('internal.s3.example.com');
    expect(result.headers['Content-Type']).toBe('image/png');
    expect(result.headers['Content-Length']).toBe('1024');
  });

  test('presigned upload URL falls back to endpoint without publicEndpoint', async () => {
    const provider = new RailwayS3Provider({
      endpoint: 'https://s3.example.com',
      bucket: 'billing-baba',
      region: 'auto',
      accessKeyId: 'test-key',
      secretAccessKey: 'test-secret',
      forcePathStyle: true,
      ssl: true,
    });

    const result = await provider.createUploadUrl({
      key: 'prod/businesses/biz/items/a.png',
      mimeType: 'image/png',
      expiresInSeconds: 900,
    });

    expect(result.url).toContain('s3.example.com');
  });
});
