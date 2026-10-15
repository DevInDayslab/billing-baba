# GST reports — data contract

Authoritative semantics for GST v2 calculators (`apps/api/src/modules/gst-reports/`).  
Source implementations: `document-tax.service.ts`, sales/purchase document services, Drizzle schema.

## Document types

### Sales (`sales_document_type` enum)

| Type | In GST outward reports |
|------|-------------------------|
| `tax_invoice`, `bill_of_supply`, `normal_invoice`, `pos` | Yes (finalized, not deleted) |
| `sales_return` | Yes (credit notes; net in aggregations) |
| `estimate` | No (includes proforma: same type, series `PI`) |
| `sale_order`, `delivery_challan` | No |
| Draft / `cancelled` / `converted` | No |

### Purchases (`purchase_document_type` enum)

| Type | In GST inward reports |
|------|------------------------|
| `purchase_bill` | Yes |
| `purchase_return` | Yes (debit notes; net in aggregations) |
| `purchase_order` | No |

## Status and flags

- **Included:** `status = finalized`, `is_deleted = false`.
- **`is_gst_formal`:** Stored on header; tax lines may still have amounts. v2 filters primarily by document type + status (see assumptions in plan).
- **`party_state_code`:** Place of supply for reporting; 2-digit state code string when set. If null, treat as business state for classification and emit `MISSING_PARTY_STATE` warning.

## Line tax fields (persisted at save time)

Columns on `sales_document_lines` / `purchase_document_lines`:

- `quantity`, `unit`, `unit_price`, `discount_amount`
- `tax_type`: `none` | `cgst_sgst` | `igst` (see `tax_type` enum)
- `tax_rate` (percent, money string)
- `cgst_amount`, `sgst_amount`, `igst_amount`
- `line_total`

## TCS / TDS and `total_amount` (taxes group)

- **`total_amount`** on sale/purchase headers is the amount the party owes or is credited (includes **TCS** when enabled).
- **`tax_amount`** is GST only; it does **not** include TCS.
- **TCS** header fields: `tcs_section_id`, `tcs_rate`, `tcs_base_amount`, `tcs_amount` (default 0).
- **Revenue / purchase turnover / P&L** reporting uses `documentCommercialTotal(total_amount, tcs_amount) = total_amount - tcs_amount`.
- **Balances, ledger, allocations** use full `total_amount`.
- **TDS** on payments: gross settled **G** is allocated to invoices; `payments.amount` = cash = G − TDS; separate `ledger_entries` with `entry_type = tds` for the withheld portion.
- Phase 1+: `cess_rate`, `cess_amount` (default `0`)

Tax is computed in `calculateLineTax()` (`apps/api/src/shared/documents/document-tax.service.ts`):

- **Tax-exclusive (default):** `taxable = max(0, qty * unit_price - discount)`; tax from rate and `tax_type`; `line_total = taxable + tax`.
- **Tax-inclusive (`taxInclusive: true` on input):** `taxable` back-calculated from gross; `line_total = gross - discount`.

**Note:** Line rows in DB do not store a separate `taxable_amount` column. For reports use:

```text
line_taxable = line_total - cgst_amount - sgst_amount - igst_amount - cess_amount
```

(all as decimal strings, summed with `gst-money` helpers in the gst-reports module).

Header `subtotal` from `sumDocumentTotals()` is **sum of qty × unit_price** (gross), not sum of line taxable values. Prefer line-derived taxable for HSN/GSTR sections; header `total_amount` for B2CL threshold.

## `tax_type` meaning

| Value | When set |
|-------|----------|
| `none` | `is_gst_formal` false, or no GST |
| `cgst_sgst` | Intra-state GST (`resolveTaxType`: same business/party state, or missing state defaults to CGST/SGST) |
| `igst` | Inter-state GST |

Inter-state detection for classification: `business.state_code != party_state_code` **or** any line `igst_amount > 0`.

## Credit / debit notes and amounts

- Credit note: `document_type = sales_return`. Debit note: `purchase_return`.
- **Stored amounts are positive** (quantity, line totals, header `total_amount`). Stock movement uses positive qty delta on return (`sales-finalize.service.ts`). Ledger posts credit = `total_amount` on return.
- **Calculators apply negative multipliers** when netting into summary buckets (HSN qty/value, GSTR 3.1, ITC).

## Original invoice linkage

- Existing: `converted_from_id` on sales/purchase documents.
- Phase 1+: `original_document_id`, `original_document_number`, `original_document_date` (populated from linked invoice when known). CDNR/CDNUR rows use these when present; otherwise warning `CREDIT_NOTE_MISSING_ORIGINAL`.

## Party registration

- Registered: `parties.gstin` non-empty and passes `gstin-validator` format + checksum.
- No separate registration-type column.

## Business profile

- `businesses.gstin`, `businesses.state_code` (required on business).

## Units / UQC

- Line `unit` is free text from item/transaction; map to GST UQC via `uqc-mapper` (gst-reports core).

## Worked example (tax-exclusive, intra-state)

From `document-tax.test.ts`:

- qty `2`, unit price `100`, discount `0`, rate `18%`, `cgst_sgst`
- Taxable = 200; CGST = 9, SGST = 9; `line_total` = 236
- Report line taxable = 236 - 9 - 9 = **200**

## Worked example (tax-inclusive)

- qty `1`, unit price `118`, rate `18%`, inclusive → `line_total` = 118, CGST/SGST > 0, taxable ≈ 100.
