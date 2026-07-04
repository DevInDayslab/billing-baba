ALTER TABLE "purchase_documents" ADD COLUMN "is_gst_formal" boolean DEFAULT false NOT NULL;--> statement-breakpoint
ALTER TABLE "purchase_documents" ADD COLUMN "party_state_code" text;--> statement-breakpoint
ALTER TABLE "purchase_documents" ADD COLUMN "discount_total" numeric(18, 4) DEFAULT '0' NOT NULL;--> statement-breakpoint
ALTER TABLE "purchase_documents" ADD COLUMN "converted_from_id" uuid;--> statement-breakpoint
ALTER TABLE "purchase_documents" ADD COLUMN "supplier_invoice_number" text;--> statement-breakpoint
ALTER TABLE "purchase_documents" ADD COLUMN "due_date" date;--> statement-breakpoint
ALTER TABLE "purchase_documents" ADD COLUMN "notes" text;--> statement-breakpoint
ALTER TABLE "purchase_document_lines" ADD COLUMN "discount_amount" numeric(18, 4) DEFAULT '0' NOT NULL;--> statement-breakpoint
ALTER TABLE "purchase_document_lines" ADD COLUMN "cgst_amount" numeric(18, 4) DEFAULT '0' NOT NULL;--> statement-breakpoint
ALTER TABLE "purchase_document_lines" ADD COLUMN "sgst_amount" numeric(18, 4) DEFAULT '0' NOT NULL;--> statement-breakpoint
ALTER TABLE "purchase_document_lines" ADD COLUMN "igst_amount" numeric(18, 4) DEFAULT '0' NOT NULL;--> statement-breakpoint
ALTER TABLE "purchase_document_lines" ADD COLUMN "sort_order" integer DEFAULT 0 NOT NULL;--> statement-breakpoint
ALTER TABLE "purchase_documents" ADD CONSTRAINT "purchase_documents_converted_from_id_purchase_documents_id_fk" FOREIGN KEY ("converted_from_id") REFERENCES "public"."purchase_documents"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "purchase_document_lines" ADD CONSTRAINT "purchase_document_lines_quantity_positive" CHECK ("purchase_document_lines"."quantity" > 0);--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_purchase_documents_business_document_date" ON "purchase_documents" USING btree ("business_id","document_date");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_purchase_documents_business_party_date" ON "purchase_documents" USING btree ("business_id","party_id","document_date");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_purchase_documents_business_document_number" ON "purchase_documents" USING btree ("business_id","document_number");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_purchase_documents_sync_pull" ON "purchase_documents" USING btree ("business_id","updated_at") WHERE "purchase_documents"."is_deleted" = false;--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_purchase_document_lines_purchase_document_id" ON "purchase_document_lines" USING btree ("purchase_document_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_payment_allocations_purchase_document_id" ON "payment_allocations" USING btree ("purchase_document_id");
