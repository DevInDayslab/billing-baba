import { describe, expect, test } from 'bun:test';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

describe('inventory sync index migration', () => {
  test('0051 is journaled and creates required indexes', () => {
    const journalPath = join(
      process.cwd(),
      'drizzle/migrations/meta/_journal.json',
    );
    const journal = JSON.parse(readFileSync(journalPath, 'utf8')) as {
      entries: Array<{ idx: number; tag: string }>;
    };
    const tags = journal.entries.map((entry) => entry.tag);
    expect(tags).toContain('0051_item_sync_indexes');

    const sql = readFileSync(
      join(process.cwd(), 'drizzle/migrations/0051_item_sync_indexes.sql'),
      'utf8',
    );
    expect(sql).toContain('idx_item_alternatives_sync_pull');
    expect(sql).toContain('idx_item_tier_prices_sync_pull');
    expect(sql).toContain('uq_item_tier_prices_item_tier_active');
  });
});
