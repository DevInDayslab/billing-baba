CREATE TABLE IF NOT EXISTS "expense_items" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"name" text NOT NULL,
	"hsn_sac" text,
	"price" numeric(18, 4) DEFAULT '0' NOT NULL,
	"price_is_tax_inclusive" boolean DEFAULT false NOT NULL,
	"tax_rate" numeric(18, 4) DEFAULT '0' NOT NULL,
	"sync_version" integer DEFAULT 0 NOT NULL,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"created_by" uuid,
	"updated_by" uuid,
	"device_id" text
);
--> statement-breakpoint
ALTER TABLE "expense_items" ADD CONSTRAINT "expense_items_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;
--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "uq_expense_items_business_name" ON "expense_items" USING btree ("business_id",lower("name")) WHERE "expense_items"."is_deleted" = false;
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_expense_items_sync_pull" ON "expense_items" USING btree ("business_id","updated_at") WHERE "expense_items"."is_deleted" = false;
--> statement-breakpoint
ALTER TABLE "expenses" ADD COLUMN IF NOT EXISTS "expense_item_id" uuid;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "expenses" ADD CONSTRAINT "expenses_expense_item_id_expense_items_id_fk" FOREIGN KEY ("expense_item_id") REFERENCES "public"."expense_items"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
