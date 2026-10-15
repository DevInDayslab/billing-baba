CREATE TYPE "public"."withholding_tax_kind" AS ENUM('tds', 'tcs');
--> statement-breakpoint
CREATE TYPE "public"."withholding_tax_direction" AS ENUM('payable', 'receivable');
--> statement-breakpoint
CREATE TYPE "public"."withholding_applicable_on" AS ENUM('sale', 'purchase', 'payment_in', 'payment_out');
--> statement-breakpoint
CREATE TYPE "public"."tax_deposit_kind" AS ENUM('tds', 'tcs');
--> statement-breakpoint
ALTER TYPE "public"."ledger_entry_type" ADD VALUE IF NOT EXISTS 'tds';
--> statement-breakpoint
ALTER TABLE "parties" ADD COLUMN IF NOT EXISTS "pan" text;
--> statement-breakpoint
ALTER TABLE "businesses" ADD COLUMN IF NOT EXISTS "pan" text;
--> statement-breakpoint
ALTER TABLE "businesses" ADD COLUMN IF NOT EXISTS "tan" text;
--> statement-breakpoint
ALTER TABLE "business_settings" ADD COLUMN IF NOT EXISTS "enable_tds" boolean DEFAULT false NOT NULL;
--> statement-breakpoint
ALTER TABLE "business_settings" ADD COLUMN IF NOT EXISTS "enable_tcs" boolean DEFAULT false NOT NULL;
--> statement-breakpoint
ALTER TABLE "sales_documents" ADD COLUMN IF NOT EXISTS "tcs_section_id" uuid;
--> statement-breakpoint
ALTER TABLE "sales_documents" ADD COLUMN IF NOT EXISTS "tcs_rate" numeric(18, 4);
--> statement-breakpoint
ALTER TABLE "sales_documents" ADD COLUMN IF NOT EXISTS "tcs_base_amount" numeric(18, 4) DEFAULT '0';
--> statement-breakpoint
ALTER TABLE "sales_documents" ADD COLUMN IF NOT EXISTS "tcs_amount" numeric(18, 4) DEFAULT '0';
--> statement-breakpoint
ALTER TABLE "purchase_documents" ADD COLUMN IF NOT EXISTS "tcs_section_id" uuid;
--> statement-breakpoint
ALTER TABLE "purchase_documents" ADD COLUMN IF NOT EXISTS "tcs_rate" numeric(18, 4);
--> statement-breakpoint
ALTER TABLE "purchase_documents" ADD COLUMN IF NOT EXISTS "tcs_base_amount" numeric(18, 4) DEFAULT '0';
--> statement-breakpoint
ALTER TABLE "purchase_documents" ADD COLUMN IF NOT EXISTS "tcs_amount" numeric(18, 4) DEFAULT '0';
--> statement-breakpoint
ALTER TABLE "payments" ADD COLUMN IF NOT EXISTS "tds_section_id" uuid;
--> statement-breakpoint
ALTER TABLE "payments" ADD COLUMN IF NOT EXISTS "tds_rate" numeric(18, 4);
--> statement-breakpoint
ALTER TABLE "payments" ADD COLUMN IF NOT EXISTS "tds_amount" numeric(18, 4) DEFAULT '0';
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "withholding_tax_sections" (
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
  "kind" "withholding_tax_kind" NOT NULL,
  "code" text NOT NULL,
  "description" text NOT NULL,
  "rate" numeric(18, 4) NOT NULL,
  "applicable_on" "withholding_applicable_on" NOT NULL,
  "is_active" boolean DEFAULT true NOT NULL,
  "is_preloaded" boolean DEFAULT false NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "tax_deposits" (
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
  "kind" "tax_deposit_kind" NOT NULL,
  "bsr_code" text NOT NULL,
  "challan_serial" text NOT NULL,
  "deposit_date" date NOT NULL,
  "amount" numeric(18, 4) NOT NULL,
  "notes" text
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "withholding_tax_entries" (
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
  "kind" "withholding_tax_kind" NOT NULL,
  "direction" "withholding_tax_direction" NOT NULL,
  "section_id" uuid,
  "section_code" text NOT NULL,
  "rate" numeric(18, 4) NOT NULL,
  "base_amount" numeric(18, 4) NOT NULL,
  "tax_amount" numeric(18, 4) NOT NULL,
  "party_id" uuid,
  "party_pan" text,
  "party_name" text,
  "source_type" text NOT NULL,
  "source_id" uuid NOT NULL,
  "entry_date" timestamp with time zone NOT NULL,
  "deposit_id" uuid,
  "certificate_no" text,
  "certificate_date" date
);
