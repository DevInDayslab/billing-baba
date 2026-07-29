-- Sync pull indexes on (business_id, updated_at). Skip tables that are not present.
DO $$ BEGIN
  IF to_regclass('public.categories') IS NOT NULL THEN
    CREATE INDEX IF NOT EXISTS "idx_categories_sync_pull" ON "categories" USING btree ("business_id","updated_at") WHERE "categories"."is_deleted" = false;
  END IF;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  IF to_regclass('public.parties') IS NOT NULL THEN
    CREATE INDEX IF NOT EXISTS "idx_parties_sync_pull" ON "parties" USING btree ("business_id","updated_at") WHERE "parties"."is_deleted" = false;
  END IF;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  IF to_regclass('public.items') IS NOT NULL THEN
    CREATE INDEX IF NOT EXISTS "idx_items_sync_pull" ON "items" USING btree ("business_id","updated_at") WHERE "items"."is_deleted" = false;
  END IF;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  IF to_regclass('public.unit_definitions') IS NOT NULL THEN
    CREATE INDEX IF NOT EXISTS "idx_unit_definitions_sync_pull" ON "unit_definitions" USING btree ("business_id","updated_at") WHERE "unit_definitions"."is_deleted" = false;
  END IF;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  IF to_regclass('public.tax_rates') IS NOT NULL THEN
    CREATE INDEX IF NOT EXISTS "idx_tax_rates_sync_pull" ON "tax_rates" USING btree ("business_id","updated_at") WHERE "tax_rates"."is_deleted" = false;
  END IF;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  IF to_regclass('public.godowns') IS NOT NULL THEN
    CREATE INDEX IF NOT EXISTS "idx_godowns_sync_pull" ON "godowns" USING btree ("business_id","updated_at") WHERE "godowns"."is_deleted" = false;
  END IF;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  IF to_regclass('public.brands') IS NOT NULL THEN
    CREATE INDEX IF NOT EXISTS "idx_brands_sync_pull" ON "brands" USING btree ("business_id","updated_at") WHERE "brands"."is_deleted" = false;
  END IF;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  IF to_regclass('public.leads') IS NOT NULL THEN
    CREATE INDEX IF NOT EXISTS "idx_leads_sync_pull" ON "leads" USING btree ("business_id","updated_at") WHERE "leads"."is_deleted" = false;
  END IF;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  IF to_regclass('public.lead_activities') IS NOT NULL THEN
    CREATE INDEX IF NOT EXISTS "idx_lead_activities_sync_pull" ON "lead_activities" USING btree ("business_id","updated_at") WHERE "lead_activities"."is_deleted" = false;
  END IF;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  IF to_regclass('public.contacts') IS NOT NULL THEN
    CREATE INDEX IF NOT EXISTS "idx_contacts_sync_pull" ON "contacts" USING btree ("business_id","updated_at") WHERE "contacts"."is_deleted" = false;
  END IF;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  IF to_regclass('public.contact_activities') IS NOT NULL THEN
    CREATE INDEX IF NOT EXISTS "idx_contact_activities_sync_pull" ON "contact_activities" USING btree ("business_id","updated_at") WHERE "contact_activities"."is_deleted" = false;
  END IF;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  IF to_regclass('public.deals') IS NOT NULL THEN
    CREATE INDEX IF NOT EXISTS "idx_deals_sync_pull" ON "deals" USING btree ("business_id","updated_at") WHERE "deals"."is_deleted" = false;
  END IF;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  IF to_regclass('public.expense_categories') IS NOT NULL THEN
    CREATE INDEX IF NOT EXISTS "idx_expense_categories_sync_pull" ON "expense_categories" USING btree ("business_id","updated_at") WHERE "expense_categories"."is_deleted" = false;
  END IF;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  IF to_regclass('public.expenses') IS NOT NULL THEN
    CREATE INDEX IF NOT EXISTS "idx_expenses_sync_pull" ON "expenses" USING btree ("business_id","updated_at") WHERE "expenses"."is_deleted" = false;
  END IF;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  IF to_regclass('public.business_settings') IS NOT NULL THEN
    CREATE INDEX IF NOT EXISTS "idx_business_settings_sync_pull" ON "business_settings" USING btree ("business_id","updated_at") WHERE "business_settings"."is_deleted" = false;
  END IF;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  IF to_regclass('public.sales_documents') IS NOT NULL THEN
    CREATE INDEX IF NOT EXISTS "idx_sales_documents_sync_pull" ON "sales_documents" USING btree ("business_id","updated_at") WHERE "sales_documents"."is_deleted" = false;
  END IF;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  IF to_regclass('public.sales_document_lines') IS NOT NULL THEN
    CREATE INDEX IF NOT EXISTS "idx_sales_document_lines_sync_pull" ON "sales_document_lines" USING btree ("business_id","updated_at") WHERE "sales_document_lines"."is_deleted" = false;
  END IF;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  IF to_regclass('public.purchase_documents') IS NOT NULL THEN
    CREATE INDEX IF NOT EXISTS "idx_purchase_documents_sync_pull" ON "purchase_documents" USING btree ("business_id","updated_at") WHERE "purchase_documents"."is_deleted" = false;
  END IF;
END $$;
--> statement-breakpoint
DO $$ BEGIN
  IF to_regclass('public.purchase_document_lines') IS NOT NULL THEN
    CREATE INDEX IF NOT EXISTS "idx_purchase_document_lines_sync_pull" ON "purchase_document_lines" USING btree ("business_id","updated_at") WHERE "purchase_document_lines"."is_deleted" = false;
  END IF;
END $$;
