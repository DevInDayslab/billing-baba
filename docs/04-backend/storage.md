# Object Storage

## Purpose

Provider-agnostic object storage platform for Billing Baba. Binary files live in Railway Object Storage (S3-compatible). PostgreSQL stores metadata only via `media_assets`.

**Related:** [01-architecture.md](../01-architecture.md) · [05-api.md](../05-api.md) · [ADR-023](../09-decisions.md#adr-023-provider-agnostic-object-storage)

## Phase 1 scope

This document covers the **production storage platform**: provider abstraction, metadata, generated documents, image variants, transaction attachments, and WhatsApp media resolution.

**Implemented:** branding assets, item gallery/rack photos, polymorphic transaction attachments, generated PDFs (client upload + server `ensure()`), image variant processing, delete cascade for derivatives.

**Out of scope (future):** party/KYC attachments, offline attachment queue, CDN fronting, orphan S3 GC sweeper.

## Architecture

```
Client
  → POST /storage/uploads          (intent + presigned PUT URL)
  → PUT  {upload_url}              (bytes go directly to Railway — API never proxies)
  → POST /storage/uploads/complete (HEAD verify + mark ready)
  → GET  /storage/files/:id/url    (signed or public URL)

Business modules (future)
  → StorageService only
  → never import @aws-sdk/*
```

```
StorageService
      ↓
StorageProvider (interface)
      ↓
RailwayS3Provider  →  Railway S3 bucket
```

Future providers (same interface): AWS S3, Cloudflare R2, MinIO, GCS, Azure Blob.

## Upload lifecycle

1. Client requests an upload intent with `purpose`, `visibility`, `mime_type`, `file_size`.
2. `StorageService` validates MIME/size, builds a storage key, inserts `media_assets` with `status=pending`.
3. Provider returns a **presigned PUT URL**.
4. Client uploads bytes **directly** to Railway.
5. Client calls complete with `intent_id`.
6. Service `head()`s the object, verifies presence (and Content-Type when present), sets `status=ready`, stores `etag` / verified size.
7. Download via signed GET (private/authenticated) or public base URL (public).

## Storage paths

All keys are built by `buildStoragePath` — do not hardcode path fragments elsewhere.

```
{env}/businesses/{businessId}/{purposeDir}/[{ownerType}/{ownerId}/]{assetId}.{ext}
```

Examples:

```
prod/businesses/{businessId}/branding/{assetId}.png
prod/businesses/{businessId}/items/item/{itemId}/{assetId}.jpg
prod/businesses/{businessId}/parties/{assetId}.webp
prod/businesses/{businessId}/sales/...
prod/businesses/{businessId}/purchases/...
prod/businesses/{businessId}/expenses/...
prod/businesses/{businessId}/reports/...
prod/businesses/{businessId}/backups/...
```

`env` is `development` | `production` | `test` from `NODE_ENV`.

## Visibility

| Value | Download behavior |
|-------|-------------------|
| `private` | Short-lived signed GET URL |
| `authenticated` | Short-lived signed GET URL (same as private in Phase 1; auth is API-gate) |
| `public` | `S3_PUBLIC_BASE_URL/{key}` or constructed path-style URL |

## Allowed MIME types

- `image/png`
- `image/jpeg`
- `image/webp`
- `application/pdf`

Max size: `STORAGE_MAX_FILE_BYTES` (default 10 MB).

## Configuration

| Variable | Required | Notes |
|----------|----------|-------|
| `S3_ENDPOINT` | All-or-nothing | |
| `S3_BUCKET` | All-or-nothing | |
| `S3_ACCESS_KEY_ID` | All-or-nothing | |
| `S3_SECRET_ACCESS_KEY` | All-or-nothing | Never log |
| `S3_REGION` | No | Default `auto` |
| `S3_FORCE_PATH_STYLE` | No | Default `true` |
| `S3_SSL` | No | Default `true` |
| `S3_PUBLIC_BASE_URL` | No | Public asset base |
| `STORAGE_MAX_FILE_BYTES` | No | Default `10485760` |
| `STORAGE_UPLOAD_URL_TTL_SECONDS` | No | Default `900` |
| `STORAGE_DOWNLOAD_URL_TTL_SECONDS` | No | Default `3600` |

If **any** of the four required credentials is set, **all** must be set or the process fails at startup. If **none** are set, storage is disabled and `/storage/*` returns `503 STORAGE_NOT_CONFIGURED`.

## API

Prefix: `{API_PREFIX}/storage` (e.g. `/api/v1/storage`)

Auth: Bearer + business selected.

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/storage/uploads` | Create upload intent |
| `POST` | `/storage/uploads/complete` | Verify + mark ready |
| `GET` | `/storage/files/:id` | Metadata |
| `GET` | `/storage/files/:id/url` | Download URL |
| `DELETE` | `/storage/files/:id` | Soft-delete + remove object |

## Database

Table `media_assets` — server-owned registry. Soft delete via `is_deleted` / `deleted_at`. Status: `pending` | `ready`.

Business tables (`businesses.logo_url`, `item_images`, etc.) are **not** modified in Phase 1. Later phases bind domain FKs to `media_assets.id` or store `storage_key`.

## Code map

| Path | Role |
|------|------|
| `src/providers/storage/` | Provider interface + Railway implementation |
| `src/modules/storage/` | Service, repository, routes, path builder |
| `src/db/schema/storage/tables.ts` | `media_assets` |
| `docs/04-backend/storage.md` | This document |

## Phase 2 — Business branding & account avatar

Phase 2 binds `media_assets` to business branding fields and account avatars. Business modules use **`BusinessBrandingService` / `AccountAvatarService`**, which call **`StorageService` only** (never S3 SDK).

### Database (`0024_business_branding_media`)

| Table | Columns |
|-------|---------|
| `businesses` | `logo_media_asset_id`, `signature_media_asset_id`, `stamp_media_asset_id`, `upi_qr_media_asset_id` |
| `accounts` | `avatar_media_asset_id` |
| `media_assets` | `business_id` nullable (account-scoped avatars) |

Legacy URL columns (`logo_url`, `signature_url`, `avatar_url`) remain as denormalized cache populated when an upload completes.

### Business branding API

All routes require JWT + business scope. **Owner/manager** only for mutations.

| Method | Path | Body (intent) | Body (complete) |
|--------|------|---------------|-----------------|
| POST | `/business/logo` | `{ mime_type, file_size }` | `{ intent_id }` |
| DELETE | `/business/logo` | — | — |
| POST | `/business/signature` | same | same |
| DELETE | `/business/signature` | — | — |
| POST | `/business/stamp` | same | same |
| DELETE | `/business/stamp` | — | — |
| POST | `/business/upi-qr` | same | same |
| DELETE | `/business/upi-qr` | — | — |

### Account avatar API

| Method | Path |
|--------|------|
| POST | `/auth/me/avatar` |
| DELETE | `/auth/me/avatar` |

### Validation policies

| Asset | Max size | MIME |
|-------|----------|------|
| Logo | 2 MB | PNG, JPEG, WEBP |
| Signature | 1 MB | PNG |
| Stamp | 1 MB | PNG |
| UPI QR | 1 MB | PNG |
| Avatar | 2 MB | PNG, JPEG, WEBP |

### Upload flow (business modules)

1. `POST /business/{asset}` with `mime_type` + `file_size` → presigned PUT intent  
2. Client PUT bytes to Railway  
3. `POST /business/{asset}` with `intent_id` → complete + bind `media_asset` to entity  
4. `GET /business/profile` and `GET /auth/me` resolve fresh download URLs via `StorageService`

Storage keys for branding: `{env}/businesses/{businessId}/branding/{kind}/{assetId}.{ext}`  
Account avatars: `{env}/accounts/{accountId}/avatar/{assetId}.{ext}`

## Phase 3 — Inventory media

Item gallery images and rack location photos bind to `media_assets` via `ItemMediaService`. Business/inventory modules use **StorageService only** — never S3 directly.

### Schema

| Table / column | Change |
|----------------|--------|
| `item_images` | `media_asset_id` FK (nullable during migration) |
| `item_locations` | `photo_media_asset_id` FK |

Legacy `image_url` / `photo_url` columns remain as denormalized cache.

### Gallery API

| Method | Path | Body (intent) | Body (complete) |
|--------|------|---------------|-----------------|
| GET | `/inventory/items/:id/images` | — | — |
| POST | `/inventory/items/:id/images` | `{ mime_type, file_size }` | `{ intent_id, is_primary?, sort_order?, replaces_image_id? }` |
| PUT | `/inventory/items/:id/images/reorder` | `{ image_ids: uuid[] }` | — |
| PATCH | `/inventory/items/:id/images/:imageId` | `{ is_primary: true }` (primary only) | — |
| DELETE | `/inventory/items/:id/images/:imageId` | — | — |

Legacy URL POST (`image_url`) remains for backward compatibility.

### Rack photo API

| Method | Path |
|--------|------|
| POST | `/inventory/item-locations/:id/photo` |
| DELETE | `/inventory/item-locations/:id/photo` |

### Validation

| Asset | Max size | MIME |
|-------|----------|------|
| Item gallery | 2 MB | PNG, JPEG, WEBP |
| Rack photo | 2 MB | PNG, JPEG, WEBP |

Max gallery images per item: **20**.

### Upload flow

1. `POST` with `mime_type` + `file_size` → presigned PUT intent (`purpose: items`, `ownerType: item` or `rack`)  
2. Client PUT bytes to Railway  
3. `POST` with `intent_id` → complete + bind `media_asset`  
4. `scheduleItemThumbnailGeneration()` — no-op hook for future thumbnail worker

Storage keys: `{env}/businesses/{businessId}/items/{itemId}/{assetId}.{ext}` (gallery), rack photos under location owner.

## Phase 6 — Transaction attachments

Polymorphic `document_attachments` binds files to any supported transaction via `entity_type` + `entity_id`. Modules use **`DocumentAttachmentService` → StorageService only**.

### Schema (`0026_document_attachments`)

| Column | Purpose |
|--------|---------|
| `entity_type` | `sale`, `purchase`, `estimate`, `sale_order`, `purchase_order`, `delivery_challan`, `payment_in`, `payment_out`, `expense`, `job_work` |
| `entity_id` | UUID of parent transaction row |
| `media_asset_id` | FK to `media_assets` |
| `file_name`, `file_url`, `mime_type`, `attachment_kind` | Metadata + denormalized URL cache |
| `sort_order`, `label` | Ordering and display |

### API

Prefix: `/api/v1/document-attachments` (JWT + business scope)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/document-attachments?entity_type=&entity_id=` | List attachments |
| POST | `/document-attachments?entity_type=&entity_id=` | Upload intent (`mime_type`, `file_size`) or complete (`intent_id`, `file_name`, `replaces_attachment_id?`) |
| GET | `/document-attachments/:id/url` | Fresh download URL |
| PATCH | `/document-attachments/:id` | Rename (`file_name`, `label`) |
| DELETE | `/document-attachments/:id` | Soft-delete row + storage object |

### Validation

| Asset | Max size | MIME |
|-------|----------|------|
| Transaction attachment | 10 MB | PNG, JPEG, WEBP, PDF |

Max **30** attachments per transaction.

### Entity resolution

| `entity_type` | Parent table / filter |
|---------------|----------------------|
| `sale` | `sales_documents` — tax_invoice, bill_of_supply, normal_invoice, pos, sales_return |
| `estimate` | `sales_documents.document_type = estimate` |
| `sale_order` | `sales_documents.document_type = sale_order` |
| `delivery_challan` | `sales_documents.document_type = delivery_challan` |
| `purchase` | `purchase_documents` — purchase_bill, purchase_return |
| `purchase_order` | `purchase_documents.document_type = purchase_order` |
| `payment_in` | `payments.direction = received` |
| `payment_out` | `payments.direction = paid` |
| `expense` | `expenses` |
| `job_work` | `job_work_orders` |

Storage purpose mapping: sales → `sales`, purchases → `purchases`, expenses → `expenses`, payments → `payments`, job_work → `job_work`.

Closes [ADR-021](../09-decisions.md#adr-021-sales-document-attachments).

## Phase 7 — Generated documents

Cached PDF/CSV/Excel exports for share and download. Client generates bytes locally; API stores via **`GeneratedDocumentService` → `StorageService.storeFromBuffer`** and reuses the object until the source `sync_version` changes.

### Schema (`0027_generated_documents`)

| Column | Purpose |
|--------|---------|
| `document_kind` | `invoice_pdf`, `estimate_pdf`, `receipt_pdf`, `delivery_challan_pdf`, `purchase_pdf`, `report_pdf`, `excel`, `csv` |
| `source_type` | `sale_document`, `purchase_document`, `payment`, `report` |
| `source_id` | Parent entity UUID (report fingerprint UUID for exports) |
| `source_version` | Parent `sync_version` at generation time — cache invalidates when this diverges |
| `media_asset_id` | FK to `media_assets` |
| `public_token` | Unguessable token for public download endpoints |

### Cache flow

1. Client `GET /generated-documents/lookup` — returns cached metadata + URLs when `source_version` matches.
2. On miss, client generates PDF/CSV/XLSX locally and `POST /generated-documents/ensure` with `content_base64`.
3. API stores object, upserts `generated_documents`, returns `cached: false`.
4. Subsequent shares reuse the stored file until the parent document's `sync_version` increments.

### API

Prefix: `/api/v1/generated-documents` (JWT + business scope)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/generated-documents/lookup` | Check cache (`document_kind`, `source_type`, `source_id`) |
| POST | `/generated-documents/ensure` | Store or return cached (`content_base64`, optional `force_regenerate`) |
| GET | `/generated-documents/:id/url` | Fresh signed download URL |
| POST | `/generated-documents/:id/regenerate` | Force replace stored file |

Public (no auth):

| Method | Path | Description |
|--------|------|-------------|
| GET | `/public/generated-documents/:token` | Metadata + signed download URL |
| GET | `/public/generated-documents/:token/file` | 302 redirect to file |

### Validation

| Export | Max size | MIME |
|--------|----------|------|
| PDF kinds | 20 MB | `application/pdf` |
| CSV | 20 MB | `text/csv` |
| Excel | 20 MB | `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet` |

Storage paths use `reports`, `sales`, `purchases`, or `payments` purpose segments. New invoice PDFs use the canonical key:

```
{env}/businesses/{businessId}/sales/{saleId}/generated/invoice.pdf
```

See **[generated-documents.md](./generated-documents.md)** for cache semantics.

## Phase 8 — WhatsApp media

Invoice WhatsApp notify attaches a **temporary preview PNG**, not the PDF. See **[notifications.md](./notifications.md)** and **[ADR-024](../09-decisions.md#adr-024-invoice-artifact-system)**.

```
POST /sales-documents/:id/notify
  → InvoiceArtifactService.ensurePdf()
  → InvoiceArtifactService.generatePreview()
  → StorageService.storeFromBuffer (temporary sales/{saleId}/previews/*.png)
  → NotificationService.sendSaleInvoice({ mediaUrl: previewSignedUrl })
  → delete temporary preview on success
```

### Permanent vs temporary objects

| Artifact | Persistence | Path pattern |
|----------|-------------|--------------|
| Invoice PDF | Permanent (cached until `source_version` changes) | `{env}/businesses/{id}/sales/{saleId}/generated/invoice.pdf` |
| WhatsApp preview PNG | Temporary | `{env}/businesses/{id}/sales/{saleId}/previews/{uuid}.png` |
| UPI payment QR | Never stored | Generated per request |
| Public HTML | Never stored | Website SPA fetches JSON |

Configure an object-storage lifecycle rule on `*/previews/*` with **24 hour expiry** as a safety net when eager delete fails.

### Public website

See **[public-invoices.md](./public-invoices.md)**. `GET /public/invoices/:token` includes logo URL, payment/UPI metadata, and `pdf_download_path`.

## Phase 9 — Image processing

Server-side derivative generation via **`MediaProcessingService`** (see **[media-processing.md](./media-processing.md)**), integrated with **`StorageService`**. Business modules are unchanged — they upload via storage; processing runs automatically after upload completes.

### Features

- Policy-driven optimization (item, logo, avatar, attachment, rack photo)
- Staging upload → canonical replace → delete staging
- Variants: `thumbnail` (256px), `medium` (800px), `original` (policy max, default 1600px)
- WEBP q82 / JPEG q84 fallback; lossless WEBP / PNG for transparency
- EXIF stripped via auto-orient + re-encode
- Dimension validation (max 8000px edge, 64MP decompression guard)
- UUID-based processed keys: `{assetId}-{thumb|medium|original}.webp`

### Schema

- `0028_media_image_variants` — variant index table
- `0029_media_processing_metadata` — processing columns on `media_assets`

### API

Prefix: `/api/v1/storage/images` (JWT + business scope)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/storage/images/:sourceAssetId/process` | Re-run processing |
| GET | `/storage/images/:sourceAssetId/variants` | List variants + signed URLs |
| GET | `/storage/images/:sourceAssetId/variants/:variant/url` | Single variant download URL |

### Auto-trigger

After a ready **image** upload completes, `MediaProcessingService.schedule` runs **asynchronously** from `StorageService.completeUpload` / `completeAccountUpload`. Failures are logged; upload completion still succeeds.

### Delete cascade

`StorageService.deleteAsset` calls `MediaProcessingService.deleteVariantsForSource` (variant rows, child assets, staging keys).

## Generated documents — server-side PDF ensure

`POST /generated-documents/ensure` orchestrates cache lookup, optional client bytes (`content_base64`), or **server PDF generation** via `GeneratedDocumentPdfGenerator` (pdfkit MVP templates).

| Step | Behavior |
|------|----------|
| 1 | `lookup` — return cached row when `source_version` matches |
| 2 | Client bytes provided | existing `ensureStored` path (Flutter offline sync) |
| 3 | Cache miss, no bytes | render PDF from DB entities → `storeFromBuffer` |
| 4 | Return row with signed + public URLs |

Server templates mirror public invoice data — not Flutter print pixel-parity (known gap).

## Future phases

6. Backup archives, OCR persistence  
7. Pending-upload TTL sweeper, full orphan S3 GC
