DO $$ BEGIN
  CREATE TYPE "gateway_payment_intent_type" AS ENUM(
    'payment_in',
    'payment_out',
    'sale_invoice',
    'purchase_bill',
    'pos',
    'party_outstanding',
    'advance'
  );
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "gateway_payment_intent_status" AS ENUM(
    'created',
    'checkout_open',
    'callback_received',
    'verifying',
    'verified',
    'failed',
    'cancelled',
    'expired'
  );
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "gateway_reconciliation_job_status" AS ENUM(
    'pending',
    'processing',
    'completed',
    'failed'
  );
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

ALTER TYPE "payment_source" ADD VALUE IF NOT EXISTS 'razorpay_gateway';

CREATE TABLE IF NOT EXISTS "gateway_payment_intents" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "business_id" uuid NOT NULL,
  "intent_type" "gateway_payment_intent_type" NOT NULL,
  "intent_payload_version" integer DEFAULT 1 NOT NULL,
  "intent_payload" jsonb NOT NULL,
  "business_name" text NOT NULL,
  "customer_name" text NOT NULL,
  "customer_phone" text,
  "customer_email" text,
  "amount_paise" integer NOT NULL,
  "currency" text DEFAULT 'INR' NOT NULL,
  "razorpay_order_id" text NOT NULL,
  "razorpay_payment_id" text,
  "status" "gateway_payment_intent_status" DEFAULT 'created' NOT NULL,
  "idempotency_key" text,
  "accounting_payment_id" uuid,
  "failure_reason" text,
  "paid_at" timestamp with time zone,
  "verified_at" timestamp with time zone,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  "updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE IF NOT EXISTS "gateway_reconciliation_jobs" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "intent_id" uuid NOT NULL,
  "event" text NOT NULL,
  "razorpay_order_id" text NOT NULL,
  "razorpay_payment_id" text,
  "payload" jsonb,
  "status" "gateway_reconciliation_job_status" DEFAULT 'pending' NOT NULL,
  "attempts" integer DEFAULT 0 NOT NULL,
  "last_error" text,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  "processed_at" timestamp with time zone
);

DO $$ BEGIN
  ALTER TABLE "gateway_payment_intents"
    ADD CONSTRAINT "gateway_payment_intents_business_id_businesses_id_fk"
    FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id")
    ON DELETE no action ON UPDATE no action;
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE "gateway_payment_intents"
    ADD CONSTRAINT "gateway_payment_intents_accounting_payment_id_payments_id_fk"
    FOREIGN KEY ("accounting_payment_id") REFERENCES "public"."payments"("id")
    ON DELETE no action ON UPDATE no action;
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE "gateway_reconciliation_jobs"
    ADD CONSTRAINT "gateway_reconciliation_jobs_intent_id_gateway_payment_intents_id_fk"
    FOREIGN KEY ("intent_id") REFERENCES "public"."gateway_payment_intents"("id")
    ON DELETE no action ON UPDATE no action;
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_gateway_payment_intents_razorpay_order_id"
  ON "gateway_payment_intents" USING btree ("razorpay_order_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_gateway_payment_intents_razorpay_payment_id"
  ON "gateway_payment_intents" USING btree ("razorpay_payment_id")
  WHERE "razorpay_payment_id" IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_gateway_payment_intents_idempotency_key"
  ON "gateway_payment_intents" USING btree ("idempotency_key")
  WHERE "idempotency_key" IS NOT NULL;

CREATE INDEX IF NOT EXISTS "idx_gateway_payment_intents_business_status"
  ON "gateway_payment_intents" USING btree ("business_id", "status");

CREATE INDEX IF NOT EXISTS "idx_gateway_reconciliation_jobs_status"
  ON "gateway_reconciliation_jobs" USING btree ("status", "created_at");
