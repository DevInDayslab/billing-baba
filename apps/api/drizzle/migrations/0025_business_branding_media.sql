-- Phase 2: bind media_assets to business branding and account avatars

ALTER TABLE "media_assets" ALTER COLUMN "business_id" DROP NOT NULL;

ALTER TABLE "businesses" ADD COLUMN "logo_media_asset_id" uuid;
ALTER TABLE "businesses" ADD COLUMN "signature_media_asset_id" uuid;
ALTER TABLE "businesses" ADD COLUMN "stamp_media_asset_id" uuid;
ALTER TABLE "businesses" ADD COLUMN "upi_qr_media_asset_id" uuid;

ALTER TABLE "accounts" ADD COLUMN "avatar_media_asset_id" uuid;

CREATE INDEX "idx_businesses_logo_media_asset" ON "businesses" ("logo_media_asset_id");
CREATE INDEX "idx_businesses_signature_media_asset" ON "businesses" ("signature_media_asset_id");
CREATE INDEX "idx_businesses_stamp_media_asset" ON "businesses" ("stamp_media_asset_id");
CREATE INDEX "idx_businesses_upi_qr_media_asset" ON "businesses" ("upi_qr_media_asset_id");
CREATE INDEX "idx_accounts_avatar_media_asset" ON "accounts" ("avatar_media_asset_id");
