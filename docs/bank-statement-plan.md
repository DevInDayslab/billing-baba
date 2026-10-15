# Bank Statement — execution plan

Living checklist for Bank Statement / Cash & Bank implementation. Tick phases as completed.

## Phases

| Phase | Goal | Status |
|-------|------|--------|
| 0 | Data contract + this doc | [x] |
| 1 | Migration 0061 + Drizzle schema | [x] |
| 2 | Pure domain + unit tests | [x] |
| 3 | Bank account master API + sync | [x] |
| 4 | AccountMovementService + writers | [x] |
| 5 | Transfers, adjustments, tax deposit | [x] |
| 6 | Backfill script | [x] |
| 7 | POS multi-payment finalize | [x] |
| 8 | Client Drift + sync (v31) | [x] |
| 9 | BankAccountPicker + PaymentAccountField | [x] |
| 10 | Cash & Bank page | [x] |
| 11 | Statement API v2 | [x] |
| 12 | Statement UI desktop + mobile | [x] |
| 13 | Dashboard bank balance | [x] |
| 14 | Cleanup + architecture docs | [x] |

## Money writers → AccountMovementService

| # | File | Operation | Movement |
|---|------|-----------|----------|
| 1 | `apps/api/src/modules/accounting/payment.service.ts` `createPayment` | insert | recordForSource |
| 2 | `payment.service.ts` `deletePayment` | soft delete | voidForSource |
| 3 | `sales-finalize-payment.service.ts` | insert payment | recordForSource |
| 4 | `purchase-finalize-payment.service.ts` | insert payment | recordForSource |
| 5 | `payment-gateway.service.ts` | createPayment | recordForSource |
| 6 | `expense.service.ts` create/update/delete | CRUD | record/replace/void |
| 7 | `sync/apply/row-applier.ts` expenses | sync push | record/replace/void |
| 8 | `expense-sync.service.ts` linked expenses | upsert/remove | replace/void (skip non-cash sources) |
| 9 | `tax-deposit.service.ts` | create/delete | record/void |
| 10 | TransferService / AdjustmentService | CRUD | two-leg / one-leg |
| 11 | `scripts/backfill-account-movements.ts` | data | idempotent backfill |

## Assumptions to verify

- Expense `payment_mode` null → cash account.
- Payment-in discount linked expense → no movement (only `payments.amount` is cash).
- Gateway / razorpay → default bank account.
- Tax deposit without `bank_account_id` → default bank.
- Backfill Primary Bank `opening_balance_as_of` = earliest payment/expense date per business.
- Loyalty redemption expense may be excluded from movements (non-cash benefit).

## Future work

- Loan Statement hardcoded dropdown.
- Cash In Hand widget (all received payments today).
- Bank reconciliation / cheque clearance.
- Offline statement; sync payments/movements.

## Per-phase verification

- API: `cd apps/api && bun run typecheck && bunx biome check src --diagnostic-level=error`
- API tests: `cd apps/api && bun test tests`
- Client: `cd apps/client && dart format . && flutter analyze && flutter test`
