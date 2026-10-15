# Bank accounts & passbook architecture

## Overview

- **`bank_accounts`** (synced): cash + bank master per business.
- **`account_movements`** (server-only): projection written in the same DB transaction as money sources.
- **Statement**: `GET /reports/business/bank-statement?bank_account_id=…` built from movements + opening balance.

## Adding a new money feature

1. Add nullable `bank_account_id` on the source row if the user can pick an account.
2. On create/update/delete, call `AccountMovementService.recordForSource` / `replaceForSource` / `voidForSource` inside the existing transaction.
3. Resolve account with `BankAccountService.resolveAccountId(businessId, paymentMode, providedId)`.
4. Skip non-cash bookkeeping (e.g. payment-in discount expenses) via `shouldSkipExpenseMovement`.
5. Expose `bank_account_id` on API DTOs and client forms using `PaymentAccountField`.

## Client

- Drift `bank_accounts_local` (schema 31) + `BankAccountSync`.
- Cash & Bank: `/sale/cash-and-bank` under Sale menu.
- Reports: filter by `bank_account_id`, not legacy `bank_name`.

## Backfill

`bun apps/api/scripts/backfill-account-movements.ts` (`--dry-run` supported). Safe to re-run.
