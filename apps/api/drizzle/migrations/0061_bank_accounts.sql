CREATE TYPE "public"."bank_account_type" AS ENUM('cash', 'bank');
--> statement-breakpoint
CREATE TYPE "public"."account_movement_direction" AS ENUM('deposit', 'withdrawal');
--> statement-breakpoint
CREATE TYPE "public"."account_movement_type" AS ENUM(
  'payment_in',
  'payment_out',
  'expense',
  'transfer_in',
  'transfer_out',
  'adjustment_increase',
  'adjustment_decrease',
  'tax_deposit'
);
--> statement-breakpoint
CREATE TYPE "public"."account_adjustment_kind" AS ENUM('increase', 'decrease');
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "bank_accounts" (
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
  "type" "bank_account_type" NOT NULL,
  "display_name" text NOT NULL,
  "bank_name" text,
  "account_number" text,
  "ifsc" text,
  "upi_id" text,
  "opening_balance" numeric(18, 4) DEFAULT '0' NOT NULL,
  "opening_balance_as_of" date NOT NULL,
  "is_default" boolean DEFAULT false NOT NULL,
  "is_active" boolean DEFAULT true NOT NULL
);
--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "uq_bank_accounts_one_cash_per_business" ON "bank_accounts" ("business_id") WHERE "type" = 'cash' AND "is_deleted" = false;
--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "uq_bank_accounts_one_default_bank" ON "bank_accounts" ("business_id") WHERE "type" = 'bank' AND "is_default" = true AND "is_active" = true AND "is_deleted" = false;
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "bank_accounts_business_id_updated_at_is_deleted_index" ON "bank_accounts" ("business_id", "updated_at", "is_deleted");
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "account_movements" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "business_id" uuid NOT NULL,
  "bank_account_id" uuid NOT NULL,
  "direction" "account_movement_direction" NOT NULL,
  "amount" numeric(18, 4) NOT NULL,
  "occurred_at" timestamp with time zone NOT NULL,
  "movement_type" "account_movement_type" NOT NULL,
  "reference_type" text NOT NULL,
  "reference_id" uuid NOT NULL,
  "leg" smallint DEFAULT 0 NOT NULL,
  "party_id" uuid,
  "description" text NOT NULL,
  "reference_number" text,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  "is_deleted" boolean DEFAULT false NOT NULL,
  "deleted_at" timestamp with time zone,
  CONSTRAINT "account_movements_amount_positive" CHECK ("amount" > 0)
);
--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "uq_account_movements_source_leg_active" ON "account_movements" ("reference_type", "reference_id", "leg") WHERE "is_deleted" = false;
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_account_movements_stmt" ON "account_movements" ("business_id", "bank_account_id", "occurred_at", "created_at", "id");
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "account_transfers" (
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
  "from_account_id" uuid NOT NULL,
  "to_account_id" uuid NOT NULL,
  "amount" numeric(18, 4) NOT NULL,
  "transfer_date" date NOT NULL,
  "notes" text
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "account_adjustments" (
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
  "bank_account_id" uuid NOT NULL,
  "kind" "account_adjustment_kind" NOT NULL,
  "amount" numeric(18, 4) NOT NULL,
  "adjustment_date" date NOT NULL,
  "notes" text
);
--> statement-breakpoint
ALTER TABLE "payments" ADD COLUMN IF NOT EXISTS "bank_account_id" uuid;
--> statement-breakpoint
ALTER TABLE "expenses" ADD COLUMN IF NOT EXISTS "bank_account_id" uuid;
--> statement-breakpoint
ALTER TABLE "tax_deposits" ADD COLUMN IF NOT EXISTS "bank_account_id" uuid;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "bank_accounts" ADD CONSTRAINT "bank_accounts_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "account_movements" ADD CONSTRAINT "account_movements_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "account_movements" ADD CONSTRAINT "account_movements_bank_account_id_bank_accounts_id_fk" FOREIGN KEY ("bank_account_id") REFERENCES "public"."bank_accounts"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "payments" ADD CONSTRAINT "payments_bank_account_id_bank_accounts_id_fk" FOREIGN KEY ("bank_account_id") REFERENCES "public"."bank_accounts"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "expenses" ADD CONSTRAINT "expenses_bank_account_id_bank_accounts_id_fk" FOREIGN KEY ("bank_account_id") REFERENCES "public"."bank_accounts"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "tax_deposits" ADD CONSTRAINT "tax_deposits_bank_account_id_bank_accounts_id_fk" FOREIGN KEY ("bank_account_id") REFERENCES "public"."bank_accounts"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
