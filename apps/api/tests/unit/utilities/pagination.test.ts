import { describe, expect, test } from 'bun:test';
import { buildPaginationMeta } from '../../../src/shared/http/pagination';

describe('pagination', () => {
  test('builds pagination metadata', () => {
    expect(buildPaginationMeta({ page: 1, limit: 20, total: 45 })).toEqual({
      page: 1,
      limit: 20,
      total: 45,
      totalPages: 3,
    });
  });

  test('returns zero pages for empty results', () => {
    expect(
      buildPaginationMeta({ page: 1, limit: 20, total: 0 }).totalPages,
    ).toBe(0);
  });
});
