CREATE TYPE "media_image_variant" AS ENUM ('thumbnail', 'small', 'medium', 'large');

CREATE TABLE "media_image_variants" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "business_id" uuid NOT NULL REFERENCES "businesses"("id"),
  "source_media_asset_id" uuid NOT NULL REFERENCES "media_assets"("id"),
  "variant" "media_image_variant" NOT NULL,
  "media_asset_id" uuid NOT NULL REFERENCES "media_assets"("id"),
  "width" integer NOT NULL,
  "height" integer NOT NULL,
  "file_size" bigint NOT NULL,
  "mime_type" text NOT NULL DEFAULT 'image/webp',
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
