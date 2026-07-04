CREATE TYPE "public"."expense_category_type" AS ENUM('direct', 'indirect');--> statement-breakpoint
CREATE TYPE "public"."purchase_fa_status" AS ENUM('paid', 'unpaid', 'partially_paid', 'overdue', 'cancelled');--> statement-breakpoint
ALTER TABLE "expense_categories" ADD COLUMN "category_type" "expense_category_type" DEFAULT 'direct' NOT NULL;--> statement-breakpoint
CREATE UNIQUE INDEX "uq_expense_categories_business_name" ON "expense_categories" USING btree ("business_id",lower("name")) WHERE "expense_categories"."is_deleted" = false;--> statement-breakpoint
ALTER TABLE "expenses" ADD COLUMN "tax_amount" numeric(18, 4) DEFAULT '0' NOT NULL;--> statement-breakpoint
ALTER TABLE "expenses" ADD COLUMN "tax_rate" numeric(18, 4) DEFAULT '0' NOT NULL;--> statement-breakpoint
ALTER TABLE "expenses" ADD COLUMN "notes" text;--> statement-breakpoint
ALTER TABLE "expenses" ADD COLUMN "reference_number" text;--> statement-breakpoint
ALTER TABLE "expenses" ADD COLUMN "attachments" jsonb DEFAULT '[]'::jsonb;--> statement-breakpoint
CREATE TABLE "purchase_fa_batches" (
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
	"purchase_date" date NOT NULL,
	"due_date" date,
	"payment_mode" "payment_mode",
	"subtotal" numeric(18, 4) DEFAULT '0' NOT NULL,
	"tax_amount" numeric(18, 4) DEFAULT '0' NOT NULL,
	"total_amount" numeric(18, 4) DEFAULT '0' NOT NULL,
	"balance_due" numeric(18, 4) DEFAULT '0' NOT NULL,
	"status" "purchase_fa_status" DEFAULT 'unpaid' NOT NULL,
	"notes" text,
	"description" text
);--> statement-breakpoint
CREATE TABLE "purchase_fixed_assets" (
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
	"purchase_document_id" uuid,
	"asset_name" text NOT NULL,
	"asset_category" text,
	"serial_number" text,
	"purchase_price" numeric(18, 4) NOT NULL,
	"location" text,
	"warranty_expiry" date,
	"description" text,
	"qty" numeric(18, 4) DEFAULT '1' NOT NULL,
	"tax_rate" numeric(18, 4) DEFAULT '0' NOT NULL,
	"tax_amount" numeric(18, 4) DEFAULT '0' NOT NULL,
	"line_total" numeric(18, 4) NOT NULL,
	"sort_order" integer DEFAULT 0 NOT NULL
);--> statement-breakpoint
ALTER TABLE "purchase_fa_batches" ADD CONSTRAINT "purchase_fa_batches_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "purchase_fa_batches" ADD CONSTRAINT "purchase_fa_batches_party_id_parties_id_fk" FOREIGN KEY ("party_id") REFERENCES "public"."parties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "purchase_fixed_assets" ADD CONSTRAINT "purchase_fixed_assets_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "purchase_fixed_assets" ADD CONSTRAINT "purchase_fixed_assets_batch_id_purchase_fa_batches_id_fk" FOREIGN KEY ("batch_id") REFERENCES "public"."purchase_fa_batches"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "purchase_fixed_assets" ADD CONSTRAINT "purchase_fixed_assets_purchase_document_id_purchase_documents_id_fk" FOREIGN KEY ("purchase_document_id") REFERENCES "public"."purchase_documents"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "uq_purchase_fixed_assets_business_serial" ON "purchase_fixed_assets" USING btree ("business_id","serial_number") WHERE "purchase_fixed_assets"."serial_number" IS NOT NULL AND "purchase_fixed_assets"."is_deleted" = false;--> statement-breakpoint
CREATE INDEX "idx_purchase_fa_batches_business_purchase_date" ON "purchase_fa_batches" USING btree ("business_id","purchase_date");--> statement-breakpoint
CREATE INDEX "idx_expenses_business_expense_date" ON "expenses" USING btree ("business_id","expense_date");
