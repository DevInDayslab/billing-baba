# Object Storage

## Purpose

Provider-agnostic object storage platform for Billing Baba. Binary files live in Railway Object Storage (S3-compatible). PostgreSQL stores metadata only via `media_assets`.

**Related:** [01-architecture.md](../01-architecture.md) · [05-api.md](../05-api.md) · [ADR-023](../09-decisions.md#adr-023-provider-agnostic-object-storage)

## Phase 1 scope

This document describes the **storage foundation** only:

- `StorageProvider` / `RailwayS3Provider`
- `StorageService` + `media_assets`
- Generic `/storage/*` API (presigned upload / complete / download / delete)

**Not in Phase 1:** company logo, item images, party attachments, expense receipts, OCR persistence, WhatsApp media, invoice PDFs, Flutter clients, thumbnails, compression.

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

## Future phases

3. Generated PDFs for share / WhatsApp  
4. WhatsApp `sendMedia`  
5. Document attachments, KYC docs, thumbs, backup archives  
