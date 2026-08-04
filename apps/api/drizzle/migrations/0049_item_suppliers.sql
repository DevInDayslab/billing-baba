CREATE TABLE IF NOT EXISTS "item_suppliers" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"item_id" uuid NOT NULL,
	"party_id" uuid NOT NULL,
	"is_default" boolean DEFAULT false NOT NULL,
	"sort_order" integer DEFAULT 0 NOT NULL
);
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "item_suppliers" ADD CONSTRAINT "item_suppliers_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "item_suppliers" ADD CONSTRAINT "item_suppliers_item_id_items_id_fk" FOREIGN KEY ("item_id") REFERENCES "public"."items"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "item_suppliers" ADD CONSTRAINT "item_suppliers_party_id_parties_id_fk" FOREIGN KEY ("party_id") REFERENCES "public"."parties"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "uq_item_suppliers_active" ON "item_suppliers" USING btree ("business_id","item_id","party_id") WHERE "item_suppliers"."is_deleted" = false;
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_item_suppliers_item" ON "item_suppliers" USING btree ("business_id","item_id") WHERE "item_suppliers"."is_deleted" = false;
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_item_suppliers_sync_pull" ON "item_suppliers" USING btree ("business_id","updated_at") WHERE "item_suppliers"."is_deleted" = false;
