-- Phase 3: bind media_assets to item gallery images and rack location photos

ALTER TABLE "item_images" ADD COLUMN "media_asset_id" uuid;
ALTER TABLE "item_locations" ADD COLUMN "photo_media_asset_id" uuid;

CREATE INDEX "idx_item_images_media_asset" ON "item_images" ("media_asset_id");
CREATE INDEX "idx_item_locations_photo_media_asset" ON "item_locations" ("photo_media_asset_id");
