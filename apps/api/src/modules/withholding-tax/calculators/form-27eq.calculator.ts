import type { withholdingTaxEntries } from '../../../db/schema/withholding/tables';

type EntryRow = typeof withholdingTaxEntries.$inferSelect;

export function buildForm27eqRows(entries: EntryRow[]) {
  return entries.map((row) => ({
    party_name: row.partyName ?? '—',
    party_pan: row.partyPan ?? '',
    section_code: row.sectionCode,
    entry_date: row.entryDate.toISOString(),
    base_amount: row.baseAmount,
    rate: row.rate,
    tax_amount: row.taxAmount,
  }));
}

export function form27eqTotals(rows: ReturnType<typeof buildForm27eqRows>) {
  const base = rows.reduce((sum, r) => sum + Number(r.base_amount), 0);
  const tax = rows.reduce((sum, r) => sum + Number(r.tax_amount), 0);
  return {
    base_amount: base.toFixed(2),
    tax_amount: tax.toFixed(2),
  };
}
