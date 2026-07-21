# Notifications

Provider-agnostic outbound messaging (WhatsApp via Twilio, console fallback).

Related: [generated-documents.md](./generated-documents.md) · [public-invoices.md](./public-invoices.md) · [ADR-022](../09-decisions.md#adr-022-provider-agnostic-outbound-notifications) · [ADR-024](../09-decisions.md#adr-024-invoice-artifact-system)

## Architecture

Business modules call **`NotificationService` only**. Providers implement `sendText` / `sendMedia` / `sendTemplate`. User-visible copy lives in `apps/api/src/notifications/templates.ts`.

## Invoice notify flow

```
POST /api/v1/sales/sales-documents/:id/notify
  → InvoiceShareService.ensureShareLink()
  → InvoiceArtifactService.ensurePdf()
  → InvoiceArtifactService.generatePreview()     // Vyapar-style PNG
  → InvoiceArtifactService.uploadTemporaryPreview()
  → NotificationService.sendSaleInvoice({ mediaUrl: previewSignedUrl, invoiceUrl })
  → TwilioWhatsAppProvider.sendMedia
  → on success: InvoiceArtifactService.deleteTemporaryArtifacts()
```

### Hard rules

- Never call `sendMedia` with a null/empty `mediaUrl`
- Never fall back to attaching the PDF for WhatsApp — preview PNG is required
- On preview failure, return `{ notified: false, error: { code: 'PREVIEW_GENERATION_FAILED' } }`
- Temporary preview objects live under `sales/{saleId}/previews/` and are deleted after a successful send (plus documented 24h lifecycle on the `*/previews/*` prefix)

## Message body

Sale invoice template includes an **Open Full Invoice** link (`invoice_url` → website `/invoice/{token}`).

## Idempotency

`notification_send_log` deduplicates by `idempotency_key` within `NOTIFICATION_IDEMPOTENCY_TTL_HOURS` (default 24). Invoice notify uses `invoice:{invoiceId}`.

## Other notify types

| Type | Route | Media |
|------|-------|-------|
| Payment reminder | `POST /parties/:id/reminders` | Text / Twilio Content template |
| Payment received | `POST /accounting/payments/:id/notify` | Receipt PDF (when cached) |
| Sync share invite | Collaboration module | Text |

Flutter continues to call the existing notify endpoints — no new client API for invoice artifacts.
