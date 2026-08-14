-- Sync pull indexes for item_alternatives and item_tier_prices.
-- Partial unique on item_tier_prices so soft-deleted tiers can be recreated.

CREATE INDEX IF NOT EXISTS "idx_item_alternatives_sync_pull"
  ON "item_alternatives" USING btree ("business_id", "updated_at")
  WHERE "item_alternatives"."is_deleted" = false;
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_item_tier_prices_sync_pull"
  ON "item_tier_prices" USING btree ("business_id", "updated_at")
  WHERE "item_tier_prices"."is_deleted" = false;
--> statement-breakpoint
DROP INDEX IF EXISTS "uq_item_tier_prices_item_tier";
--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "uq_item_tier_prices_item_tier_active"
  ON "item_tier_prices" USING btree ("item_id", "pricing_tier")
  WHERE "item_tier_prices"."is_deleted" = false;
