import { describe, expect, test } from 'bun:test';
import {
  decodeCursor,
  encodeCursor,
  watermarkCursor,
} from '../../../src/modules/sync/cursor';
import { pushBodySchema } from '../../../src/modules/sync/sync.schema';

describe('sync cursor', () => {
  test('round-trips encode/decode', () => {
    const encoded = encodeCursor({
      t: '2026-07-26T05:10:00.000Z',
      i: '550e8400-e29b-41d4-a716-446655440000',
    });
    const decoded = decodeCursor(encoded);
    expect(decoded.t).toBe('2026-07-26T05:10:00.000Z');
    expect(decoded.i).toBe('550e8400-e29b-41d4-a716-446655440000');
  });

  test('watermark cursor decodes', () => {
    const cursor = watermarkCursor(new Date('2026-07-26T05:10:00.000Z'));
    const decoded = decodeCursor(cursor);
    expect(decoded.t).toBe('2026-07-26T05:10:00.000Z');
    expect(decoded.i).toBe('00000000-0000-0000-0000-000000000000');
  });

  test('rejects corrupt cursor', () => {
    expect(() => decodeCursor('not-a-cursor')).toThrow();
  });
});

describe('sync pushBodySchema', () => {
  const validBatch = {
    device_id: '7f1a2b3c-4d5e-4f70-8192-a3b4c5d6e7f8',
    client_batch_id: 'c0ffeeee-0000-4000-8000-000000000001',
    mutations: [
      {
        mutation_id: 'a1111111-1111-4111-8111-111111111111',
        kind: 'row' as const,
        entity_type: 'categories' as const,
        entity_id: 'b2222222-2222-4222-8222-222222222222',
        operation: 'create' as const,
        base_sync_version: 0,
        payload: { name: 'New Category' },
        client_updated_at: '2026-07-26T05:01:00.000Z',
      },
      {
        mutation_id: 'c3333333-3333-4333-8333-333333333333',
        kind: 'command' as const,
        command: 'finalize_sale' as const,
        command_id: '9c6d8d2d-3c62-4b3c-a1cb-7a8d7d8c4d1f',
        payload: {
          document_id: '550e8400-e29b-41d4-a716-446655440000',
          local_document_number: 'LOCAL-000001',
        },
        client_updated_at: '2026-07-26T05:02:00.000Z',
      },
    ],
  };

  test('accepts hybrid row + command batch', () => {
    const result = pushBodySchema.safeParse(validBatch);
    expect(result.success).toBe(true);
  });

  test('rejects empty command name', () => {
    const result = pushBodySchema.safeParse({
      ...validBatch,
      mutations: [
        {
          mutation_id: 'c3333333-3333-4333-8333-333333333333',
          kind: 'command',
          command: '',
          command_id: '9c6d8d2d-3c62-4b3c-a1cb-7a8d7d8c4d1f',
          payload: {},
          client_updated_at: '2026-07-26T05:02:00.000Z',
        },
      ],
    });
    expect(result.success).toBe(false);
  });

  test('accepts registered row entity_type brands', () => {
    const result = pushBodySchema.safeParse({
      ...validBatch,
      mutations: [
        {
          mutation_id: 'a1111111-1111-4111-8111-111111111111',
          kind: 'row',
          entity_type: 'brands',
          entity_id: 'b2222222-2222-4222-8222-222222222222',
          operation: 'create',
          base_sync_version: 0,
          payload: { name: 'Acme' },
          client_updated_at: '2026-07-26T05:01:00.000Z',
        },
      ],
    });
    expect(result.success).toBe(true);
  });

  test('rejects unknown row entity_type', () => {
    const result = pushBodySchema.safeParse({
      ...validBatch,
      mutations: [
        {
          mutation_id: 'a1111111-1111-4111-8111-111111111111',
          kind: 'row',
          entity_type: 'not_a_real_entity',
          entity_id: 'b2222222-2222-4222-8222-222222222222',
          operation: 'create',
          base_sync_version: 0,
          payload: { name: 'Nope' },
          client_updated_at: '2026-07-26T05:01:00.000Z',
        },
      ],
    });
    expect(result.success).toBe(false);
  });

  test('rejects invalid UUID device_id', () => {
    const result = pushBodySchema.safeParse({
      ...validBatch,
      device_id: 'not-a-uuid',
    });
    expect(result.success).toBe(false);
  });

  test('rejects duplicate mutation_id', () => {
    const first = validBatch.mutations[0];
    const second = validBatch.mutations[1];
    if (!first || !second) {
      throw new Error('expected fixtures');
    }
    const result = pushBodySchema.safeParse({
      ...validBatch,
      mutations: [
        first,
        {
          ...second,
          mutation_id: first.mutation_id,
        },
      ],
    });
    expect(result.success).toBe(false);
  });

  test('rejects empty mutations', () => {
    const result = pushBodySchema.safeParse({
      ...validBatch,
      mutations: [],
    });
    expect(result.success).toBe(false);
  });
});
