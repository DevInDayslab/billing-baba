DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'parties'
      AND column_name = 'unrecovered_amount'
  ) AND NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'parties'
      AND column_name = 'hidden_ledger_balance'
  ) THEN
    ALTER TABLE "parties" RENAME COLUMN "unrecovered_amount" TO "hidden_ledger_balance";
  ELSIF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'parties'
      AND column_name = 'hidden_ledger_balance'
  ) THEN
    ALTER TABLE "parties"
      ADD COLUMN "hidden_ledger_balance" numeric(12, 2) DEFAULT '0' NOT NULL;
  END IF;
END $$;
--> statement-breakpoint
ALTER TABLE "parties" ALTER COLUMN "hidden_ledger_balance" TYPE numeric(12, 2) USING round("hidden_ledger_balance"::numeric, 2);--> statement-breakpoint
ALTER TABLE "parties" DROP CONSTRAINT IF EXISTS "parties_unrecovered_amount_check";--> statement-breakpoint
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'parties_hidden_ledger_balance_check'
  ) THEN
    ALTER TABLE "parties"
      ADD CONSTRAINT "parties_hidden_ledger_balance_check"
      CHECK ("hidden_ledger_balance" >= 0);
  END IF;
END $$;
--> statement-breakpoint
CREATE TYPE "public"."hidden_ledger_entry_status" AS ENUM('pending', 'partial', 'recovered');--> statement-breakpoint
CREATE TABLE "hidden_ledger_entries" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"party_id" uuid NOT NULL,
	"sale_id" uuid,
	"invoice_id" uuid,
	"amount" numeric(18, 4) NOT NULL,
	"recovered_amount" numeric(18, 4) DEFAULT '0' NOT NULL,
	"remaining_amount" numeric(18, 4) NOT NULL,
	"status" "hidden_ledger_entry_status" DEFAULT 'pending' NOT NULL,
	"created_by" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid
);
--> statement-breakpoint
CREATE TABLE "hidden_ledger_recovery_records" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"ledger_entry_id" uuid NOT NULL,
	"sale_id" uuid,
	"recovered_amount" numeric(18, 4) NOT NULL,
	"recovered_by" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid
);
--> statement-breakpoint
ALTER TABLE "hidden_ledger_entries" ADD CONSTRAINT "hidden_ledger_entries_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "hidden_ledger_entries" ADD CONSTRAINT "hidden_ledger_entries_party_id_parties_id_fk" FOREIGN KEY ("party_id") REFERENCES "public"."parties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "hidden_ledger_entries" ADD CONSTRAINT "hidden_ledger_entries_sale_id_sales_documents_id_fk" FOREIGN KEY ("sale_id") REFERENCES "public"."sales_documents"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "hidden_ledger_entries" ADD CONSTRAINT "hidden_ledger_entries_invoice_id_sales_documents_id_fk" FOREIGN KEY ("invoice_id") REFERENCES "public"."sales_documents"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "hidden_ledger_entries" ADD CONSTRAINT "hidden_ledger_entries_created_by_users_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "hidden_ledger_recovery_records" ADD CONSTRAINT "hidden_ledger_recovery_records_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "hidden_ledger_recovery_records" ADD CONSTRAINT "hidden_ledger_recovery_records_ledger_entry_id_hidden_ledger_entries_id_fk" FOREIGN KEY ("ledger_entry_id") REFERENCES "public"."hidden_ledger_entries"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "hidden_ledger_recovery_records" ADD CONSTRAINT "hidden_ledger_recovery_records_sale_id_sales_documents_id_fk" FOREIGN KEY ("sale_id") REFERENCES "public"."sales_documents"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "hidden_ledger_recovery_records" ADD CONSTRAINT "hidden_ledger_recovery_records_recovered_by_users_id_fk" FOREIGN KEY ("recovered_by") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "idx_hidden_ledger_entries_business_party" ON "hidden_ledger_entries" USING btree ("business_id","party_id") WHERE "hidden_ledger_entries"."is_deleted" = false;--> statement-breakpoint
CREATE INDEX "idx_hidden_ledger_recovery_records_entry" ON "hidden_ledger_recovery_records" USING btree ("business_id","ledger_entry_id") WHERE "hidden_ledger_recovery_records"."is_deleted" = false;--> statement-breakpoint
ALTER TABLE "hidden_ledger_entries" ADD CONSTRAINT "hidden_ledger_entries_amount_check" CHECK ("amount" > 0);--> statement-breakpoint
ALTER TABLE "hidden_ledger_entries" ADD CONSTRAINT "hidden_ledger_entries_recovered_amount_check" CHECK ("recovered_amount" >= 0);--> statement-breakpoint
ALTER TABLE "hidden_ledger_entries" ADD CONSTRAINT "hidden_ledger_entries_remaining_amount_check" CHECK ("remaining_amount" >= 0);--> statement-breakpoint
ALTER TABLE "hidden_ledger_entries" ADD CONSTRAINT "hidden_ledger_entries_recovered_lte_amount_check" CHECK ("recovered_amount" <= "amount");--> statement-breakpoint
ALTER TABLE "hidden_ledger_recovery_records" ADD CONSTRAINT "hidden_ledger_recovery_records_recovered_amount_check" CHECK ("recovered_amount" > 0);
