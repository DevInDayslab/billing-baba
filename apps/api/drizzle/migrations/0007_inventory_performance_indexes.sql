CREATE INDEX IF NOT EXISTS "idx_items_business_category_active" ON "items" USING btree ("business_id","category_id") WHERE "items"."is_deleted" = false;--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_items_business_brand_active" ON "items" USING btree ("business_id","brand_id") WHERE "items"."is_deleted" = false;--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_items_business_hsn_active" ON "items" USING btree ("business_id","hsn_code") WHERE "items"."is_deleted" = false AND "items"."hsn_code" IS NOT NULL;--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_inventory_movements_business_item_created" ON "inventory_movements" USING btree ("business_id","item_id","created_at" DESC);--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_item_price_history_business_item_created" ON "item_price_history" USING btree ("business_id","item_id","created_at" DESC);--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_stock_levels_business_godown_active" ON "stock_levels" USING btree ("business_id","godown_id") WHERE "stock_levels"."is_deleted" = false;--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_stock_levels_business_item_active" ON "stock_levels" USING btree ("business_id","item_id") WHERE "stock_levels"."is_deleted" = false;
