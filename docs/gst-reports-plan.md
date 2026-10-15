# GST Reports v2 — living plan

Linked spec: [gst-reports-data-contract.md](./gst-reports-data-contract.md)  
Architecture (after Phase 11): [gst-reports-architecture.md](./gst-reports-architecture.md)

## Phases

- [x] **Phase 0** — Data contract + this plan
- [x] **Phase 1** — Schema (Drizzle 0059, Drift v29, sync/DTOs)
- [x] **Phase 2** — API `gst-reports` core (money, period, classifier, repository)
- [x] **Phase 3** — HSN + SAC endpoints
- [x] **Phase 4** — GSTR-1 + GSTN JSON
- [x] **Phase 5** — GSTR-3B + ITC utilisation
- [x] **Phase 6** — GSTR-2
- [x] **Phase 7** — GSTR-9
- [x] **Phase 8** — E2E integration seed test
- [x] **Phase 9** — Client definitions + scaffold + provider
- [x] **Phase 10** — GstExportService + GSTN client export
- [x] **Phase 11** — Legacy cleanup + architecture doc

## Assumptions to verify

1. Return documents store **positive** monetary amounts; calculators negate for netting (verified in `sales-finalize.service.ts` ledger/stock).
2. B2CL threshold uses header **`total_amount`** (invoice value including tax).
3. **Exports** only when `supply_type` ≠ `domestic` (column added Phase 1; no UI yet).
4. Outward inclusion by **document type + status**; not gated on `is_gst_formal` unless product changes.
5. ITC eligible = purchase from supplier with **valid GSTIN**; RCM/reversals reported as zero.
6. **GSTN offline JSON** mappers are best-effort (no official schema in repo).
7. **Composition scheme** not modeled.
8. **Offline** GST reports out of scope (API-only).

## Verification log

| Phase | Commands | Result |
|-------|----------|--------|
| 0 | docs only | pass |
| 1–11 | `bun test` (gst-reports), `bun run typecheck`, `dart run build_runner build`, `flutter analyze` (GST paths) | pass |
