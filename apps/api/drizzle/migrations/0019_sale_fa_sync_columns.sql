ALTER TABLE "sale_fa_batches" ADD COLUMN IF NOT EXISTS "device_id" uuid;--> statement-breakpoint
ALTER TABLE "sale_fixed_assets" ADD COLUMN IF NOT EXISTS "device_id" uuid;--> statement-breakpoint
ALTER TABLE "sale_fa_batches" ALTER COLUMN "sync_version" SET DEFAULT 1;--> statement-breakpoint
ALTER TABLE "sale_fixed_assets" ALTER COLUMN "sync_version" SET DEFAULT 1;--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_sale_fa_batches_business_sale_date" ON "sale_fa_batches" USING btree ("business_id","sale_date");
