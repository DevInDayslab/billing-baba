-- Party profile images: bind media_assets + denormalized signed URL cache
-- Renames legacy face_image_url → profile_image_url (unused by API before this)

ALTER TABLE "parties" RENAME COLUMN "face_image_url" TO "profile_image_url";
--> statement-breakpoint
ALTER TABLE "parties" ADD COLUMN "profile_media_asset_id" uuid;
--> statement-breakpoint
CREATE INDEX "idx_parties_profile_media_asset" ON "parties" ("profile_media_asset_id");
