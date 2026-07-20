import { describe, expect, test } from 'bun:test';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

describe('drizzle migration journal', () => {
  test('includes 0025_item_media in contiguous order', () => {
    const journalPath = join(
      process.cwd(),
      'drizzle/migrations/meta/_journal.json',
    );
    const journal = JSON.parse(readFileSync(journalPath, 'utf8')) as {
      entries: Array<{ idx: number; tag: string }>;
    };

    const tags = journal.entries.map((entry) => entry.tag);
    expect(tags).toContain('0025_item_media');

    const idxs = journal.entries.map((entry) => entry.idx);
    for (let i = 0; i < idxs.length; i++) {
      expect(idxs[i]).toBe(i);
    }

    const itemMediaIndex = tags.indexOf('0025_item_media');
    expect(tags[itemMediaIndex - 1]).toBe('0024_business_branding_media');
    expect(tags[itemMediaIndex + 1]).toBe('0026_document_attachments');
    expect(tags).toContain('0029_media_processing_metadata');
  });
});
