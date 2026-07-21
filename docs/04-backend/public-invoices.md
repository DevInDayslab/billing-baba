# Public Invoices

Token-gated public invoice pages for customers (Vyapar-style share experience).

Related: [generated-documents.md](./generated-documents.md) · [notifications.md](./notifications.md) · [ADR-024](../09-decisions.md#adr-024-invoice-artifact-system)

## Token model

Table: `invoice_share_tokens`

| Field | Purpose |
|-------|---------|
| `token` | Cryptographically random (32-byte base64url) |
| `expires_at` | Configurable via `INVOICE_SHARE_EXPIRY_DAYS` (default 90) |
| `revoked_at` | Soft revoke — public access returns 410 |
| `created_by` | Account used for best-effort PDF ensure on public view |

**One active token per invoice** (`revoked_at IS NULL` and not expired).

### Authenticated routes

| Method | Path | Behavior |
|--------|------|----------|
| POST | `/api/v1/sales/sales-documents/:id/share` | Create or reuse active token |
| POST | `/api/v1/sales/sales-documents/:id/share/revoke` | Revoke active token |
| POST | `/api/v1/sales/sales-documents/:id/share/regenerate` | Revoke all active + create new |

### Public routes

| Method | Path | Behavior |
|--------|------|----------|
| GET | `/api/v1/public/invoices/:token` | Invoice JSON (company, customer, lines, payment, PDF path) |
| GET | `/api/v1/public/invoices/:token/payment-qr` | PNG QR (or `?format=json`) |
| GET | `/api/v1/public/invoices/:token/download` | Canonical PDF: signed URL for stored `generated/invoice.pdf` (generates professional PDF once if missing) |

Expired or revoked tokens → **410**. Unknown → **404**. No authentication.

## Website

`apps/website` route: `/invoice/:token` (share URL = `{WEBSITE_URL}/invoice/{token}`).

Features:

- Responsive invoice view (light theme)
- Download PDF via `GET /public/invoices/:token/download` (signed URL to canonical Railway object — never regenerates a legacy template when `invoice.pdf` already exists)
- Print
- Share (`navigator.share` / clipboard)
- Scan to Pay modal (dynamic UPI QR from current balance + `businesses.upi_id`)

HTML is **not** stored — the SPA fetches JSON on each visit.

## Download PDF pipeline

```
Download button
  → GET /api/v1/public/invoices/:token/download
  → Lookup generated_documents for sale invoice.pdf
  → If object exists in Railway → return signed URL immediately
  → Else generate public-invoice HTML PDF via Chromium (same layout as the website page),
     store as …/sales/{id}/generated/invoice.pdf, upsert generated_documents,
     return signed URL
```

Tiny legacy pdfkit text invoices are replaced automatically on the next download. Noto Sans is embedded so ₹ renders correctly.

## Scan to Pay

Requires:

- Non-empty `businesses.upi_id` (VPA)
- `due_amount > 0`

Payload:

```
upi://pay?pa={upiId}&pn={companyName}&am={dueAmount}&mam=0.01&tn=Invoice_{invoiceNumber}&cu=INR
```

QR is generated on demand via `PaymentQrService` — never stored.

## Security

- Tokens are unguessable; do not enumerate
- Signed URLs for logos and PDFs — never raw storage keys
- Payment QR always uses **current** balance and UPI ID
