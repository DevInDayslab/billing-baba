-- Phase 9: Media processing metadata on media_assets + evolved variant enum

ALTER TABLE "media_assets"
  ADD COLUMN IF NOT EXISTS "width" integer,
  ADD COLUMN IF NOT EXISTS "height" integer,
  ADD COLUMN IF NOT EXISTS "format" text,
  ADD COLUMN IF NOT EXISTS "variant_type" text,
  ADD COLUMN IF NOT EXISTS "parent_asset_id" uuid REFERENCES "media_assets"("id"),
  ADD COLUMN IF NOT EXISTS "original_size" bigint,
  ADD COLUMN IF NOT EXISTS "optimized_size" bigint,
  ADD COLUMN IF NOT EXISTS "compression_ratio" numeric(8, 4),
  ADD COLUMN IF NOT EXISTS "processed_at" timestamptz,
  ADD COLUMN IF NOT EXISTS "processing_status" text NOT NULL DEFAULT 'pending',
  ADD COLUMN IF NOT EXISTS "staging_storage_key" text;

CREATE INDEX IF NOT EXISTS "idx_media_assets_parent"
  ON "media_assets" ("parent_asset_id")
  WHERE "parent_asset_id" IS NOT NULL;

CREATE INDEX IF NOT EXISTS "idx_media_assets_processing_status"
  ON "media_assets" ("processing_status")
  WHERE "processing_status" != 'skipped';

-- Evolve media_image_variant enum: thumbnail | medium | original
DELETE FROM "media_image_variants" WHERE "variant" IN ('small', 'large');

ALTER TYPE "media_image_variant" RENAME TO "media_image_variant_old";

CREATE TYPE "media_image_variant" AS ENUM ('thumbnail', 'medium', 'original');

ALTER TABLE "media_image_variants"
  ALTER COLUMN "variant" TYPE "media_image_variant"
  USING (
    CASE "variant"::text
      WHEN 'thumbnail' THEN 'thumbnail'::"media_image_variant"
      WHEN 'medium' THEN 'medium'::"media_image_variant"
      ELSE 'original'::"media_image_variant"
    END
  );

DROP TYPE "media_image_variant_old";

ALTER TABLE "media_image_variants"
  ALTER COLUMN "business_id" DROP NOT NULL;

ALTER TABLE "media_image_variants"
  ADD COLUMN IF NOT EXISTS "processing_duration_ms" integer,
  ADD COLUMN IF NOT EXISTS "compression_ratio" numeric(8, 4);
