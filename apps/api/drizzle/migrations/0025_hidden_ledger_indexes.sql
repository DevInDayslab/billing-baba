CREATE INDEX "idx_hidden_ledger_entries_business_status_created" ON "hidden_ledger_entries" USING btree ("business_id","status","created_at" DESC) WHERE "is_deleted" = false;--> statement-breakpoint
CREATE INDEX "idx_hidden_ledger_entries_business_created" ON "hidden_ledger_entries" USING btree ("business_id","created_at" DESC) WHERE "is_deleted" = false;--> statement-breakpoint
CREATE INDEX "idx_hidden_ledger_entries_invoice" ON "hidden_ledger_entries" USING btree ("business_id","invoice_id") WHERE "is_deleted" = false AND "invoice_id" IS NOT NULL;--> statement-breakpoint
CREATE INDEX "idx_hidden_ledger_recovery_records_sale" ON "hidden_ledger_recovery_records" USING btree ("business_id","sale_id") WHERE "is_deleted" = false AND "sale_id" IS NOT NULL;
