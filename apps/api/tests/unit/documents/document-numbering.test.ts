import { describe, expect, test } from 'bun:test';
import { currentFiscalYear } from '../../../src/shared/documents/document-numbering.service';

describe('document-numbering.service', () => {
  test('currentFiscalYear uses April–March Indian FY', () => {
    expect(currentFiscalYear(new Date('2026-03-15'))).toBe('2025-2026');
    expect(currentFiscalYear(new Date('2026-04-01'))).toBe('2026-2027');
  });
});
