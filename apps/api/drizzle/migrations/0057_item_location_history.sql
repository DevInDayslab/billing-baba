CREATE TABLE IF NOT EXISTS "item_location_history" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "business_id" uuid NOT NULL REFERENCES "businesses"("id"),
  "item_location_id" uuid NOT NULL REFERENCES "item_locations"("id"),
  "item_id" uuid NOT NULL REFERENCES "items"("id"),
  "rack" text,
  "shelf" text,
  "photo_url" text,
  "photo_media_asset_id" uuid,
  "employee_label" text,
  "changed_by" uuid REFERENCES "users"("id"),
  "created_at" timestamptz DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS "idx_item_location_history_location_created"
  ON "item_location_history" ("item_location_id", "created_at");
