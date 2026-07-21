# Generated Documents

Cached PDF (and future CSV/Excel) exports for share and download. The **PDF is the only permanent invoice artifact**.

Related: [storage.md](./storage.md) · [notifications.md](./notifications.md) · [public-invoices.md](./public-invoices.md) · [ADR-024](../09-decisions.md#adr-024-invoice-artifact-system)

## Service

`GeneratedDocumentService` owns cache lookup and storage:

| Method | Behavior |
|--------|----------|
| `lookup` | Return cached metadata when `source_version` matches |
| `ensure` | Return cache, store client `content_base64`, or generate server-side PDF |
| `resolveOrCreateSalePdfDownload` | Public download pipeline: signed URL for existing object, else professional generate + store |
| `getSignedDownloadUrl` | Fresh signed URL for authenticated clients |
| `getPublicFileRedirectUrl` | 302 target for public download token |

Business modules call **`InvoiceArtifactService.ensurePdf()`** / **`resolveCanonicalPdfDownload()`**, which delegates here. Do not generate invoice PDFs inside route handlers.

Sale documents use **`InvoiceDocumentPdfRenderer`**: Chromium prints the canonical public-invoice HTML (same card layout as the website InvoiceView), with Inter + Noto Sans embedded so ₹ renders correctly. Payment receipts still use a simple pdfkit layout.

## Cache key

Unique active row per `(business_id, document_kind, source_type, source_id)`.

Invalidation: when the parent entity's `sync_version` diverges from `generated_documents.source_version`, the next `ensure` regenerates.

## Canonical storage path

New `invoice_pdf` objects for sales documents use:

```
{env}/businesses/{businessId}/sales/{saleId}/generated/invoice.pdf
```

Other kinds keep the default UUID-based path under the purpose segment (`sales`, `purchases`, `payments`, `reports`).

## Public download

| Method | Path | Auth |
|--------|------|------|
| GET | `/api/v1/public/generated-documents/:token` | Public — metadata |
| GET | `/api/v1/public/generated-documents/:token/file` | Public — 302 to signed URL |

Never expose raw S3 keys to clients.

## Server PDF quality

Server generation for sale invoices uses Chromium to print the **canonical public invoice HTML** (`InvoiceDocumentPdfRenderer`) — the same visual template as the website invoice page (card, table, badge, QR, footer). Noto Sans is embedded so ₹ renders correctly.

Tiny legacy pdfkit text invoices (&lt; ~12KB) are auto-replaced on the next public download. Flutter client uploads remain valid when they are full professional PDFs.
