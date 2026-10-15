CREATE TYPE "public"."supply_type" AS ENUM(
  'domestic',
  'export_with_payment',
  'export_without_payment',
  'sez_with_payment',
  'sez_without_payment'
);
--> statement-breakpoint
ALTER TABLE "sales_documents" ADD COLUMN IF NOT EXISTS "supply_type" "supply_type" DEFAULT 'domestic' NOT NULL;
--> statement-breakpoint
ALTER TABLE "sales_documents" ADD COLUMN IF NOT EXISTS "original_document_id" uuid;
--> statement-breakpoint
ALTER TABLE "sales_documents" ADD COLUMN IF NOT EXISTS "original_document_number" text;
--> statement-breakpoint
ALTER TABLE "sales_documents" ADD COLUMN IF NOT EXISTS "original_document_date" timestamp with time zone;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "sales_documents" ADD CONSTRAINT "sales_documents_original_document_id_sales_documents_id_fk" FOREIGN KEY ("original_document_id") REFERENCES "public"."sales_documents"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
ALTER TABLE "purchase_documents" ADD COLUMN IF NOT EXISTS "original_document_id" uuid;
--> statement-breakpoint
ALTER TABLE "purchase_documents" ADD COLUMN IF NOT EXISTS "original_document_number" text;
--> statement-breakpoint
ALTER TABLE "purchase_documents" ADD COLUMN IF NOT EXISTS "original_document_date" timestamp with time zone;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "purchase_documents" ADD CONSTRAINT "purchase_documents_original_document_id_purchase_documents_id_fk" FOREIGN KEY ("original_document_id") REFERENCES "public"."purchase_documents"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
ALTER TABLE "sales_document_lines" ADD COLUMN IF NOT EXISTS "cess_rate" numeric(18, 4) DEFAULT '0' NOT NULL;
--> statement-breakpoint
ALTER TABLE "sales_document_lines" ADD COLUMN IF NOT EXISTS "cess_amount" numeric(18, 4) DEFAULT '0' NOT NULL;
--> statement-breakpoint
ALTER TABLE "purchase_document_lines" ADD COLUMN IF NOT EXISTS "cess_rate" numeric(18, 4) DEFAULT '0' NOT NULL;
--> statement-breakpoint
ALTER TABLE "purchase_document_lines" ADD COLUMN IF NOT EXISTS "cess_amount" numeric(18, 4) DEFAULT '0' NOT NULL;
