# Media Processing Engine

Production-grade, policy-driven image optimization for Billing Baba. Business modules upload images through the normal storage flow; **`MediaProcessingService`** handles validation, optimization, variant generation, and metadata updates automatically after upload completes.

See also: [Storage](./storage.md) for upload intents, object keys, and delete semantics.

## Architecture

```
Client upload
  → StorageService.createUploadIntent (staging key for images)
  → PUT to presigned URL
  → StorageService.completeUpload
  → MediaProcessingService.schedule (async, non-blocking)
      → ImageMediaProcessor
          → ImagePipeline (sharp)
          → replace canonical source + store variants
          → update media_assets + media_image_variants
```

Future processors (not implemented): `VideoProcessor`, `PDFProcessor`, `OCRProcessor`, `AudioProcessor` — all implement the same `MediaProcessor` interface.

### Module layout

| Path | Role |
|------|------|
| `apps/api/src/modules/media-processing/media-processing.service.ts` | Orchestrator, staging lifecycle, persistence |
| `apps/api/src/modules/media-processing/media-processing.constants.ts` | `ImagePolicy` registry |
| `apps/api/src/modules/media-processing/pipeline/image-pipeline.ts` | Configurable sharp pipeline |
| `apps/api/src/modules/media-processing/processors/image.processor.ts` | `ImageMediaProcessor` |
| `apps/api/src/modules/images/image.service.ts` | Thin HTTP facade for manual `/process` and variant URLs |

## Staging lifecycle

1. **Upload intent** — image uploads target a **staging key**: `{env}/businesses/{id}/staging/{assetId}.{ext}` (avatars: `{env}/accounts/{id}/staging/...`).
2. **Complete upload** — object verified via HEAD; `media_assets.processing_status = pending`.
3. **Background processing** — pipeline reads staging bytes, optimizes, writes canonical + variant objects.
4. **Success** — source row updated to `{assetId}-original.webp`; staging object deleted; `processing_status = ready`.
5. **Failure** — staging kept; `processing_status = failed`; upload still succeeds (user can view unoptimized staging URL until retry).

Non-image assets (PDF, etc.) skip processing (`processing_status = skipped`).

## ImagePolicy registry

| Policy | Purpose / trigger | Optimize | Variants | Max edge |
|--------|-------------------|----------|----------|----------|
| `ITEM_IMAGE` | `items` gallery | yes | thumb/medium/original | 1600px |
| `RACK_PHOTO` | `items` + rack owner | yes | thumb/medium/original | 1600px |
| `LOGO` | `branding` | yes | thumb/medium/original | 1024px |
| `AVATAR` | account avatar | yes | thumb/medium/original | 512px |
| `ATTACHMENT` | sales/purchases/etc. images | yes | original only | no resize |
| `PDF` | `application/pdf` | no | — | — |

Policies control whether raw uploads are kept (`keepOriginal: false` for photos; `true` for document-like assets).

## Variant strategy

| Variant | Max edge | Use case |
|---------|----------|----------|
| `thumbnail` | 256px | POS grid, lists, gallery thumbs |
| `medium` | 800px | detail views, dialogs |
| `original` | policy max (1600 default) | zoom, print |

Storage keys: `{purposeDir}/[{owner}/]{assetId}-{thumb|medium|original}.webp`

Never upscale. Raw staging uploads are not retained after successful processing.

## Compression and format rules

| Input | Output | Quality |
|-------|--------|---------|
| Opaque photo | WEBP | 82 |
| Opaque (WEBP failure) | JPEG | 84 |
| Transparent | lossless WEBP | — |
| Transparent (WEBP failure) | PNG | — |

Logos (`LOGO` policy) always preserve transparency.

## Pipeline steps (sharp)

1. Validate MIME (PNG/JPEG/WEBP only)
2. Validate magic bytes (never trust extension)
3. Reject animated images
4. Read dimensions (max 8000×8000, 64MP decompression guard)
5. Auto-rotate (EXIF orientation)
6. Strip EXIF on re-encode
7. Resize per policy (`withoutEnlargement: true`)
8. Format selection + compression
9. Generate variants

Rejected: BMP, TIFF, GIF, HEIC, SVG, executables, corrupted/malformed files.

## Database

Migration `0029_media_processing_metadata.sql` extends `media_assets`:

- `width`, `height`, `format`, `variant_type`, `parent_asset_id`
- `original_size`, `optimized_size`, `compression_ratio`
- `processed_at`, `processing_status`, `staging_storage_key`

`media_image_variants` enum: `thumbnail | medium | original` (nullable `business_id` for avatars).

## API

Prefix: `/api/v1/storage/images` (JWT + business scope)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/:sourceAssetId/process` | Re-run processing |
| GET | `/:sourceAssetId/variants` | List variants + URLs |
| GET | `/:sourceAssetId/variants/:variant/url` | Single variant URL |

Item gallery responses include `thumbnail_url` and `medium_url` when variants exist.

## Delete cascade

`StorageService.deleteAsset` → `MediaProcessingService.deleteVariantsForSource`:

- Soft-delete variant rows
- Delete variant S3 objects and child `media_assets` rows
- Delete staging key if present

## Flutter client

`AppNetworkImage` accepts optional `sourceMediaAssetId` + `ImageDisplayContext` to resolve the best variant via `MediaImageUrlResolver`. Falls back: requested variant → larger variant → source URL.

POS/list views use server-provided `thumbnail_url` on item images (resolved from primary image variant).

## Logging and metrics

Structured logs (never image bytes):

```json
{
  "event": "media.processing_complete",
  "assetId": "...",
  "policy": "ITEM_IMAGE",
  "durationMs": 842,
  "originalSize": 2400000,
  "optimizedSize": 180000,
  "compressionRatio": 0.075,
  "variants": ["thumbnail", "medium", "original"],
  "format": "webp"
}
```

`MediaProcessingMetrics` tracks aggregate compression %, latency, and failure counts (log-aggregatable today; pluggable backend later).

## Future support

- Job queue with retry for failed processing
- HEIC/AVIF input (explicit opt-in)
- Video, OCR, audio processors via `MediaProcessor` interface
- Batch backfill for pre-existing uploads
