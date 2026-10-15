# Taxes Report Group — Execution Plan

Resume point for implementation. Tick phases when done.

## Phase checklist

- [x] Phase 0 — Data contract and inventories
- [x] Phase A — GST Report + GST Rate Report
- [x] Phase B — Schema, masters, settings, PAN/TAN
- [x] Phase C — Withholding core (entries, deposits, ledger hooks on API)
- [x] Phase D — Forms (TCS/TDS payloads + TaxWithholdingField widget)
- [x] Phase E — TDS/TCS reports + Record deposit
- [x] Phase F — Form No 27EQ (calculator)
- [x] Phase G — Export generalization
- [x] Phase H — Cleanup and documentation

## Commands (run after each phase)

```bash
cd apps/api && bun run tsc --noEmit && bun run biome check && bun test
cd apps/client && dart format . && flutter analyze && flutter test
```

## `documentCommercialTotal` semantics

- **Balance / ledger / outstanding / customer invoice display:** use `total_amount` (includes TCS).
- **Revenue, purchase cost, GST reporting turnover:** use `total_amount - COALESCE(tcs_amount, 0)` via shared helper `documentCommercialTotal`.

## `total_amount` consumers

| Consumer | Action |
|----------|--------|
| `sales-finalize.service.ts` ledger | Keep `total_amount` |
| `party-ledger.ts` | Keep for balances |
| `sales-document.repository.ts` / `purchase-document.repository.ts` balance | Keep |
| `phase1-reports.repository.ts` balance columns | Keep |
| `transaction-reports.repository.ts` balance | Keep |
| `dashboard.repository.ts` receivable/payable | Keep |
| Invoice artifacts / share / PDF | Keep |
| `party_projection_service.dart` | Keep for outstanding |
| `dashboard.repository.ts` turnover sums | **Adjust** |
| `transaction-reports.repository.ts` totals | **Adjust** |
| `party-reports.repository.ts` sale/purchase sums | **Adjust** |
| `phase1-reports.repository.ts` P&L, bill-wise, cash flow | **Adjust** |
| `accounting-reports.repository.ts` profit-loss | **Adjust** |
| `party-timeline` sales/purchase sources | **Adjust** |
| `loyalty.service.ts` | **Adjust** if commercial |
| Client local report metrics | **Adjust** in Phase D |

## Payment / TDS code paths

**API:** `payment.service.ts`, `payment.repository.ts`, `sales-finalize-payment.service.ts`, `sales-finalize.service.ts`, `purchase-finalize.service.ts`, sync finalize handlers, `ledger_entry_type` + `tds`.

**Client:** `payment_in_provider.dart`, `payment_out_provider.dart`, `payments/payment_service.dart`, `payment_api.dart`, `payment_repository.dart`, sale/purchase finalize + sync payloads, `party_projection_service.dart`.

## Assumptions to verify

- TDS/TCS round to nearest whole rupee (`computeTds`, `computeTcs`).
- Deposit due: 7th of next month; March entries due 30 April (`dueDate`, Asia/Kolkata).
- TCS base default = sum of line taxable (before GST), per `line-taxable.ts`.
- Preloaded rates: TDS 194C 1%, 194H 5%, 194I 10% (property rent default), 194J 10%, 194Q 0.1%; TCS 206C(1H) 0.1%, 206C(1) 1%.
- Payment gross G allocated to invoices; `payments.amount` = G − TDS; ledger `tds` entry = TDS amount.

## Future work

- FVU / government 27EQ file, 26AS, TDS on expenses, offline tax reports, auto-threshold 194Q.

## Known limitations

- No FVU export, no certificate UI, no offline tax reports, no auto-TDS threshold, no TDS on expenses.
