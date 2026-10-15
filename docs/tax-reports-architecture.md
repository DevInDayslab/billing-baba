# Tax reports architecture

## API modules

- `apps/api/src/modules/tax-reporting/` — GST register, GST rate summary, TDS/TCS party summaries, Form 27EQ (envelope contract shared with GST v2).
- `apps/api/src/modules/withholding-tax/` — Section seed, withholding entries (from finalize/payments), tax deposits, PAN/TAN validators, `computeTds` / `computeTcs`.

## Data flow

1. **TCS on documents:** `sales_documents` / `purchase_documents` header fields → finalize services → `withholding_tax_entries`.
2. **TDS on payments:** `payments.tds_*` → ledger `entry_type = tds` + withholding entry.
3. **Deposits:** `POST /reports/tax/deposits` creates `tax_deposits` and links entry rows via `deposit_id`.
4. **Reports:** Calculators aggregate `withholding_tax_entries` into envelope sections consumed by `TaxReportScaffold` (desktop) and `MobileTaxReportDataLoader` (mobile).

## Commercial totals

Turnover and GST reporting exclude TCS using `documentCommercialTotal(total_amount, tcs_amount)`. Balances and ledger keep full `total_amount`.

## Client

- Definitions: `tax_report_definitions.dart` + `TaxReportKind`.
- Export: `definition_report_export_service.dart`.
- Offline: Drift v30 mirrors sections, entries, deposits; sync entity types registered on API `row-entities`.

## Limitations

No FVU / government file export, no 26AS, no offline tax report calculators on device (API-backed only).
