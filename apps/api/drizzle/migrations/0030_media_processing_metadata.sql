-- Phase 9: Media processing metadata on media_assets + evolved variant enum
-- Idempotent: works when 0028 was applied (old enum) or when media_image_variants is missing.

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

DO $$
BEGIN
  -- Case A: table exists with legacy enum (thumbnail|small|medium|large) → evolve
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'media_image_variants'
  ) THEN
    DELETE FROM "media_image_variants" WHERE "variant"::text IN ('small', 'large');

    IF EXISTS (
      SELECT 1 FROM pg_type t
      JOIN pg_enum e ON e.enumtypid = t.oid
      WHERE t.typname = 'media_image_variant' AND e.enumlabel = 'small'
    ) THEN
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
    END IF;

    ALTER TABLE "media_image_variants"
      ALTER COLUMN "business_id" DROP NOT NULL;

    ALTER TABLE "media_image_variants"
      ADD COLUMN IF NOT EXISTS "processing_duration_ms" integer,
      ADD COLUMN IF NOT EXISTS "compression_ratio" numeric(8, 4);

  -- Case B: 0028 never applied — create final schema directly
  ELSE
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'media_image_variant') THEN
      CREATE TYPE "media_image_variant" AS ENUM ('thumbnail', 'medium', 'original');
    END IF;

    CREATE TABLE "media_image_variants" (
      "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
      "business_id" uuid REFERENCES "businesses"("id"),
      "source_media_asset_id" uuid NOT NULL REFERENCES "media_assets"("id"),
      "variant" "media_image_variant" NOT NULL,
      "media_asset_id" uuid NOT NULL REFERENCES "media_assets"("id"),
      "width" integer NOT NULL,
      "height" integer NOT NULL,
      "file_size" bigint NOT NULL,
      "mime_type" text NOT NULL DEFAULT 'image/webp',
      "processing_duration_ms" integer,
      "compression_ratio" numeric(8, 4),
      "created_at" timestamptz NOT NULL DEFAULT now(),
      "updated_at" timestamptz NOT NULL DEFAULT now(),
      "deleted_at" timestamptz,
      "is_deleted" boolean NOT NULL DEFAULT false
    );

    CREATE UNIQUE INDEX "uq_media_image_variants_source_variant"
      ON "media_image_variants" ("source_media_asset_id", "variant")
      WHERE "is_deleted" = false;

    CREATE INDEX "idx_media_image_variants_business"
      ON "media_image_variants" ("business_id");

    CREATE INDEX "idx_media_image_variants_source"
      ON "media_image_variants" ("source_media_asset_id");
  END IF;
END $$;
