CREATE TABLE IF NOT EXISTS "item_bom_materials" (
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
	"raw_item_id" uuid NOT NULL,
	"qty" numeric(18, 4) NOT NULL,
	"unit_id" uuid NOT NULL,
	"purchase_price" numeric(18, 4) DEFAULT '0' NOT NULL,
	"sort_order" integer DEFAULT 0 NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "item_bom_costs" (
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
	"description" text NOT NULL,
	"amount" numeric(18, 4) DEFAULT '0' NOT NULL,
	"sort_order" integer DEFAULT 0 NOT NULL
);
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "item_bom_materials" ADD CONSTRAINT "item_bom_materials_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "item_bom_materials" ADD CONSTRAINT "item_bom_materials_item_id_items_id_fk" FOREIGN KEY ("item_id") REFERENCES "public"."items"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "item_bom_materials" ADD CONSTRAINT "item_bom_materials_raw_item_id_items_id_fk" FOREIGN KEY ("raw_item_id") REFERENCES "public"."items"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "item_bom_materials" ADD CONSTRAINT "item_bom_materials_unit_id_unit_definitions_id_fk" FOREIGN KEY ("unit_id") REFERENCES "public"."unit_definitions"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "item_bom_costs" ADD CONSTRAINT "item_bom_costs_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "item_bom_costs" ADD CONSTRAINT "item_bom_costs_item_id_items_id_fk" FOREIGN KEY ("item_id") REFERENCES "public"."items"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "uq_item_bom_materials_active" ON "item_bom_materials" USING btree ("business_id","item_id","raw_item_id") WHERE "item_bom_materials"."is_deleted" = false;
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_item_bom_materials_item" ON "item_bom_materials" USING btree ("business_id","item_id") WHERE "item_bom_materials"."is_deleted" = false;
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_item_bom_materials_sync_pull" ON "item_bom_materials" USING btree ("business_id","updated_at") WHERE "item_bom_materials"."is_deleted" = false;
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_item_bom_costs_item" ON "item_bom_costs" USING btree ("business_id","item_id") WHERE "item_bom_costs"."is_deleted" = false;
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_item_bom_costs_sync_pull" ON "item_bom_costs" USING btree ("business_id","updated_at") WHERE "item_bom_costs"."is_deleted" = false;
