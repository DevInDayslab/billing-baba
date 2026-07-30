ALTER TYPE "sales_document_type" ADD VALUE IF NOT EXISTS 'sale_order' BEFORE 'delivery_challan';--> statement-breakpoint
CREATE TYPE "public"."job_work_order_status" AS ENUM('open', 'closed', 'cancelled');--> statement-breakpoint
CREATE TABLE "job_work_orders" (
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
	"party_id" uuid,
	"job_number" text,
	"status" "job_work_order_status" DEFAULT 'open' NOT NULL,
	"order_date" timestamp with time zone DEFAULT now() NOT NULL,
	"delivery_date" timestamp with time zone,
	"finished_good_name" text NOT NULL,
	"finished_good_quantity" numeric(18, 4) DEFAULT '1' NOT NULL,
	"finished_good_unit" text DEFAULT 'PCS' NOT NULL,
	"raw_materials_total" numeric(18, 4) DEFAULT '0' NOT NULL,
	"additional_costs_total" numeric(18, 4) DEFAULT '0' NOT NULL,
	"grand_total" numeric(18, 4) DEFAULT '0' NOT NULL,
	"notes" text
);--> statement-breakpoint
CREATE TABLE "job_work_raw_material_lines" (
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
	"job_work_order_id" uuid NOT NULL,
	"item_id" uuid NOT NULL,
	"quantity" numeric(18, 4) NOT NULL,
	"unit" text NOT NULL,
	"purchase_price" numeric(18, 4) DEFAULT '0' NOT NULL,
	"line_total" numeric(18, 4) DEFAULT '0' NOT NULL,
	"sort_order" integer DEFAULT 0 NOT NULL
);--> statement-breakpoint
CREATE TABLE "job_work_additional_costs" (
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
	"job_work_order_id" uuid NOT NULL,
	"label" text NOT NULL,
	"amount" numeric(18, 4) DEFAULT '0' NOT NULL,
	"sort_order" integer DEFAULT 0 NOT NULL
);--> statement-breakpoint
ALTER TABLE "job_work_orders" ADD CONSTRAINT "job_work_orders_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "job_work_orders" ADD CONSTRAINT "job_work_orders_party_id_parties_id_fk" FOREIGN KEY ("party_id") REFERENCES "public"."parties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "job_work_raw_material_lines" ADD CONSTRAINT "job_work_raw_material_lines_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "job_work_raw_material_lines" ADD CONSTRAINT "job_work_raw_material_lines_job_work_order_id_job_work_orders_id_fk" FOREIGN KEY ("job_work_order_id") REFERENCES "public"."job_work_orders"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "job_work_raw_material_lines" ADD CONSTRAINT "job_work_raw_material_lines_item_id_items_id_fk" FOREIGN KEY ("item_id") REFERENCES "public"."items"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "job_work_additional_costs" ADD CONSTRAINT "job_work_additional_costs_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "job_work_additional_costs" ADD CONSTRAINT "job_work_additional_costs_job_work_order_id_job_work_orders_id_fk" FOREIGN KEY ("job_work_order_id") REFERENCES "public"."job_work_orders"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_sales_documents_business_document_date" ON "sales_documents" USING btree ("business_id","document_date");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_sales_documents_business_party_date" ON "sales_documents" USING btree ("business_id","party_id","document_date");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_sales_documents_business_document_number" ON "sales_documents" USING btree ("business_id","document_number");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_sales_documents_sync_pull" ON "sales_documents" USING btree ("business_id","updated_at") WHERE "sales_documents"."is_deleted" = false;--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_sales_document_lines_sales_document_id" ON "sales_document_lines" USING btree ("sales_document_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_payment_allocations_sales_document_id" ON "payment_allocations" USING btree ("sales_document_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_job_work_orders_business_status" ON "job_work_orders" USING btree ("business_id","status") WHERE "job_work_orders"."is_deleted" = false;--> statement-breakpoint
ALTER TABLE "sales_document_lines" ADD CONSTRAINT "sales_document_lines_quantity_positive" CHECK ("sales_document_lines"."quantity" > 0);--> statement-breakpoint
ALTER TABLE "payment_allocations" ADD CONSTRAINT "payment_allocations_xor_document" CHECK (("payment_allocations"."sales_document_id" IS NOT NULL AND "payment_allocations"."purchase_document_id" IS NULL) OR ("payment_allocations"."sales_document_id" IS NULL AND "payment_allocations"."purchase_document_id" IS NOT NULL));--> statement-breakpoint
ALTER TABLE "ledger_entries" ADD CONSTRAINT "ledger_entries_single_sided" CHECK (("ledger_entries"."debit" = 0 AND "ledger_entries"."credit" > 0) OR ("ledger_entries"."credit" = 0 AND "ledger_entries"."debit" > 0));--> statement-breakpoint
ALTER TABLE "ledger_entries" ADD CONSTRAINT "ledger_entries_debit_non_negative" CHECK ("ledger_entries"."debit" >= 0);--> statement-breakpoint
ALTER TABLE "ledger_entries" ADD CONSTRAINT "ledger_entries_credit_non_negative" CHECK ("ledger_entries"."credit" >= 0);
