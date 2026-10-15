CREATE TYPE "public"."loan_transaction_type" AS ENUM('increase', 'repayment', 'charges');
--> statement-breakpoint
ALTER TYPE "public"."account_movement_type" ADD VALUE IF NOT EXISTS 'other_income';
--> statement-breakpoint
ALTER TYPE "public"."account_movement_type" ADD VALUE IF NOT EXISTS 'loan_received';
--> statement-breakpoint
ALTER TYPE "public"."account_movement_type" ADD VALUE IF NOT EXISTS 'loan_repayment';
--> statement-breakpoint
ALTER TYPE "public"."account_movement_type" ADD VALUE IF NOT EXISTS 'loan_charges';
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "income_categories" (
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
  "name" text NOT NULL,
  "category_type" "expense_category_type" DEFAULT 'indirect' NOT NULL,
  "is_system" boolean DEFAULT false NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "income_items" (
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
  "name" text NOT NULL,
  "hsn_sac" text,
  "price" numeric(18, 4) DEFAULT '0' NOT NULL,
  "price_is_tax_inclusive" boolean DEFAULT false NOT NULL,
  "tax_rate" numeric(18, 4) DEFAULT '0' NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "other_incomes" (
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
  "category_id" uuid NOT NULL,
  "income_item_id" uuid,
  "amount" numeric(18, 4) NOT NULL,
  "quantity" numeric(18, 4),
  "tax_amount" numeric(18, 4) DEFAULT '0' NOT NULL,
  "tax_rate" numeric(18, 4) DEFAULT '0' NOT NULL,
  "description" text,
  "notes" text,
  "reference_number" text,
  "income_date" date NOT NULL,
  "payment_mode" "payment_mode",
  "bank_account_id" uuid,
  "due_date" date,
  "balance_due" numeric(18, 4) DEFAULT '0'
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "loan_accounts" (
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
  "name" text NOT NULL,
  "lender_name" text,
  "account_number" text,
  "description" text,
  "opening_outstanding" numeric(18, 4) DEFAULT '0' NOT NULL,
  "opening_balance_as_of" date NOT NULL,
  "interest_rate" numeric(18, 4),
  "term_months" integer,
  "received_bank_account_id" uuid
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "loan_transactions" (
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
  "loan_account_id" uuid NOT NULL,
  "transaction_type" "loan_transaction_type" NOT NULL,
  "transaction_date" date NOT NULL,
  "principal_amount" numeric(18, 4) DEFAULT '0' NOT NULL,
  "interest_amount" numeric(18, 4) DEFAULT '0' NOT NULL,
  "charges_amount" numeric(18, 4) DEFAULT '0' NOT NULL,
  "bank_account_id" uuid NOT NULL,
  "description" text,
  "reference_number" text
);
--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "uq_income_categories_business_name" ON "income_categories" ("business_id", lower("name")) WHERE "is_deleted" = false;
--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "uq_income_items_business_name" ON "income_items" ("business_id", lower("name")) WHERE "is_deleted" = false;
--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "uq_loan_accounts_business_name" ON "loan_accounts" ("business_id", lower("name")) WHERE "is_deleted" = false;
--> statement-breakpoint
ALTER TABLE "income_categories" ADD CONSTRAINT "income_categories_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;
--> statement-breakpoint
ALTER TABLE "income_items" ADD CONSTRAINT "income_items_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;
--> statement-breakpoint
ALTER TABLE "other_incomes" ADD CONSTRAINT "other_incomes_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;
--> statement-breakpoint
ALTER TABLE "other_incomes" ADD CONSTRAINT "other_incomes_category_id_income_categories_id_fk" FOREIGN KEY ("category_id") REFERENCES "public"."income_categories"("id") ON DELETE no action ON UPDATE no action;
--> statement-breakpoint
ALTER TABLE "other_incomes" ADD CONSTRAINT "other_incomes_income_item_id_income_items_id_fk" FOREIGN KEY ("income_item_id") REFERENCES "public"."income_items"("id") ON DELETE no action ON UPDATE no action;
--> statement-breakpoint
ALTER TABLE "other_incomes" ADD CONSTRAINT "other_incomes_bank_account_id_bank_accounts_id_fk" FOREIGN KEY ("bank_account_id") REFERENCES "public"."bank_accounts"("id") ON DELETE no action ON UPDATE no action;
--> statement-breakpoint
ALTER TABLE "loan_accounts" ADD CONSTRAINT "loan_accounts_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;
--> statement-breakpoint
ALTER TABLE "loan_accounts" ADD CONSTRAINT "loan_accounts_received_bank_account_id_bank_accounts_id_fk" FOREIGN KEY ("received_bank_account_id") REFERENCES "public"."bank_accounts"("id") ON DELETE no action ON UPDATE no action;
--> statement-breakpoint
ALTER TABLE "loan_transactions" ADD CONSTRAINT "loan_transactions_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;
--> statement-breakpoint
ALTER TABLE "loan_transactions" ADD CONSTRAINT "loan_transactions_loan_account_id_loan_accounts_id_fk" FOREIGN KEY ("loan_account_id") REFERENCES "public"."loan_accounts"("id") ON DELETE no action ON UPDATE no action;
--> statement-breakpoint
ALTER TABLE "loan_transactions" ADD CONSTRAINT "loan_transactions_bank_account_id_bank_accounts_id_fk" FOREIGN KEY ("bank_account_id") REFERENCES "public"."bank_accounts"("id") ON DELETE no action ON UPDATE no action;
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_income_categories_sync_pull" ON "income_categories" USING btree ("business_id","updated_at") WHERE "income_categories"."is_deleted" = false;
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_income_items_sync_pull" ON "income_items" USING btree ("business_id","updated_at") WHERE "income_items"."is_deleted" = false;
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_other_incomes_sync_pull" ON "other_incomes" USING btree ("business_id","updated_at") WHERE "other_incomes"."is_deleted" = false;
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_loan_accounts_sync_pull" ON "loan_accounts" USING btree ("business_id","updated_at") WHERE "loan_accounts"."is_deleted" = false;
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_loan_transactions_sync_pull" ON "loan_transactions" USING btree ("business_id","updated_at") WHERE "loan_transactions"."is_deleted" = false;
