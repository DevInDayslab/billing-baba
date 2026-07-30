CREATE TYPE "public"."sale_fa_status" AS ENUM('paid', 'unpaid', 'partially_paid', 'overdue', 'cancelled');--> statement-breakpoint
CREATE TABLE "sale_fa_batches" (
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
	"party_id" uuid NOT NULL,
	"reference_number" text,
	"sale_date" date NOT NULL,
	"due_date" date,
	"payment_mode" "payment_mode",
	"subtotal" numeric(18, 4) DEFAULT '0' NOT NULL,
	"tax_amount" numeric(18, 4) DEFAULT '0' NOT NULL,
	"total_amount" numeric(18, 4) DEFAULT '0' NOT NULL,
	"balance_due" numeric(18, 4) DEFAULT '0' NOT NULL,
	"status" "sale_fa_status" DEFAULT 'unpaid' NOT NULL,
	"notes" text,
	"description" text
);
--> statement-breakpoint
CREATE TABLE "sale_fixed_assets" (
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
	"batch_id" uuid NOT NULL,
	"purchase_fixed_asset_id" uuid,
	"asset_name" text NOT NULL,
	"item_code" text,
	"asset_category" text,
	"serial_number" text,
	"sale_price" numeric(18, 4) NOT NULL,
	"location" text,
	"description" text,
	"qty" numeric(18, 4) DEFAULT '1' NOT NULL,
	"tax_rate" numeric(18, 4) DEFAULT '0' NOT NULL,
	"tax_amount" numeric(18, 4) DEFAULT '0' NOT NULL,
	"line_total" numeric(18, 4) NOT NULL,
	"sort_order" integer DEFAULT 0 NOT NULL
);
--> statement-breakpoint
ALTER TABLE "sale_fa_batches" ADD CONSTRAINT "sale_fa_batches_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sale_fa_batches" ADD CONSTRAINT "sale_fa_batches_party_id_parties_id_fk" FOREIGN KEY ("party_id") REFERENCES "public"."parties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sale_fixed_assets" ADD CONSTRAINT "sale_fixed_assets_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sale_fixed_assets" ADD CONSTRAINT "sale_fixed_assets_batch_id_sale_fa_batches_id_fk" FOREIGN KEY ("batch_id") REFERENCES "public"."sale_fa_batches"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sale_fixed_assets" ADD CONSTRAINT "sale_fixed_assets_purchase_fixed_asset_id_purchase_fixed_assets_id_fk" FOREIGN KEY ("purchase_fixed_asset_id") REFERENCES "public"."purchase_fixed_assets"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "uq_sale_fixed_assets_business_serial" ON "sale_fixed_assets" USING btree ("business_id","serial_number") WHERE "sale_fixed_assets"."serial_number" IS NOT NULL AND "sale_fixed_assets"."is_deleted" = false;--> statement-breakpoint
CREATE INDEX "idx_sale_fa_batches_business_sale_date" ON "sale_fa_batches" USING btree ("business_id","sale_date");
