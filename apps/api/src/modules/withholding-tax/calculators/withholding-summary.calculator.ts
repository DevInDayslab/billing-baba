import type { withholdingTaxEntries } from '../../../db/schema/withholding/tables';

type EntryRow = typeof withholdingTaxEntries.$inferSelect;

export function buildWithholdingSummaryRows(rows: EntryRow[]) {
  const byParty = new Map<
    string,
    {
      party_name: string;
      party_pan: string;
      entry_count: number;
      base_amount: number;
      tax_amount: number;
      pending: number;
    }
  >();

  for (const row of rows) {
    const key = row.partyId ?? row.partyName ?? 'unknown';
    const current = byParty.get(key) ?? {
      party_name: row.partyName ?? '—',
      party_pan: row.partyPan ?? '',
      entry_count: 0,
      base_amount: 0,
      tax_amount: 0,
      pending: 0,
    };
    current.entry_count += 1;
    current.base_amount += Number(row.baseAmount);
    current.tax_amount += Number(row.taxAmount);
    if (!row.depositId) {
      current.pending += Number(row.taxAmount);
    }
    byParty.set(key, current);
  }

  return [...byParty.values()].map((row) => ({
    party_name: row.party_name,
    party_pan: row.party_pan,
    entry_count: row.entry_count,
    base_amount: row.base_amount.toFixed(2),
    tax_amount: row.tax_amount.toFixed(2),
    pending: row.pending.toFixed(2),
  }));
}

export function summaryTotals(rows: ReturnType<typeof buildWithholdingSummaryRows>) {
  const base = rows.reduce((sum, r) => sum + Number(r.base_amount), 0);
  const tax = rows.reduce((sum, r) => sum + Number(r.tax_amount), 0);
  const pending = rows.reduce((sum, r) => sum + Number(r.pending), 0);
  return {
    base_amount: base.toFixed(2),
    tax_amount: tax.toFixed(2),
    pending: pending.toFixed(2),
  };
}
