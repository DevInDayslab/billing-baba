import 'dotenv/config';
import { getDb } from '../src/db/client';
import { OutstandingRepository } from '../src/modules/accounting/outstanding.repository';
import { buildPartyLedgerReport } from '../src/shared/reporting/party-ledger';

const businessId = 'b234a35a-f0b1-4fcc-915b-dbf2c46328fa';
const partyId = '89267c46-3cba-4a50-b858-e26a26fc0e14';

const db = getDb()!;

const report = await buildPartyLedgerReport(db, businessId, partyId);
const repo = new OutstandingRepository(db);
const balance = await repo.getPartyBalance(businessId, partyId);

console.log('Engine outstanding:', report.summary.outstanding.toFixed(2));
console.log('Outstanding repo:', balance);
console.log('Total sales:', report.summary.totalSales.toFixed(2));
console.log('Total payments:', report.summary.totalPayments.toFixed(2));
console.log('Entries:', report.entries.length);

let running = report.openingBalance;
for (const entry of [...report.entries].sort((a, b) =>
  a.date.localeCompare(b.date),
)) {
  running += Number(entry.debit) - Number(entry.credit);
  console.log(
    entry.date,
    entry.entryType,
    `D=${entry.debit}`,
    `C=${entry.credit}`,
    `run=${running.toFixed(2)}`,
  );
}
