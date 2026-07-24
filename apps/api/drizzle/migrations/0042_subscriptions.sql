DO $$ BEGIN
 CREATE TYPE "public"."subscription_plan" AS ENUM('no_plan', 'gold', 'platinum');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "public"."subscription_status" AS ENUM('active', 'expired', 'pending', 'cancelled');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "public"."payment_status" AS ENUM('created', 'paid', 'failed', 'refunded');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
ALTER TABLE "businesses" ADD COLUMN IF NOT EXISTS "current_plan" "subscription_plan" DEFAULT 'no_plan' NOT NULL;
--> statement-breakpoint
ALTER TABLE "businesses" ADD COLUMN IF NOT EXISTS "plan_status" "subscription_status" DEFAULT 'active' NOT NULL;
--> statement-breakpoint
ALTER TABLE "businesses" ADD COLUMN IF NOT EXISTS "plan_expires_at" timestamp with time zone;
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "subscription_plans" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"plan" "subscription_plan" NOT NULL,
	"name" text NOT NULL,
	"price" numeric(18, 4) DEFAULT '0' NOT NULL,
	"duration_days" integer DEFAULT 0 NOT NULL,
	"is_active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "uq_subscription_plans_plan" ON "subscription_plans" USING btree ("plan");
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "subscriptions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"plan" "subscription_plan" NOT NULL,
	"status" "subscription_status" DEFAULT 'pending' NOT NULL,
	"starts_at" timestamp with time zone,
	"expires_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "subscription_payments" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"subscription_id" uuid,
	"plan" "subscription_plan" NOT NULL,
	"amount" numeric(18, 4) NOT NULL,
	"currency" text DEFAULT 'INR' NOT NULL,
	"razorpay_order_id" text NOT NULL,
	"razorpay_payment_id" text,
	"payment_status" "payment_status" DEFAULT 'created' NOT NULL,
	"paid_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "subscription_history" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"old_plan" "subscription_plan" NOT NULL,
	"new_plan" "subscription_plan" NOT NULL,
	"event" text NOT NULL,
	"metadata" jsonb,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "subscriptions" ADD CONSTRAINT "subscriptions_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "subscription_payments" ADD CONSTRAINT "subscription_payments_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "subscription_payments" ADD CONSTRAINT "subscription_payments_subscription_id_subscriptions_id_fk" FOREIGN KEY ("subscription_id") REFERENCES "public"."subscriptions"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "subscription_history" ADD CONSTRAINT "subscription_history_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_subscriptions_business_status" ON "subscriptions" USING btree ("business_id","status");
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_subscriptions_expires_at" ON "subscriptions" USING btree ("expires_at");
--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "uq_subscription_payments_razorpay_order_id" ON "subscription_payments" USING btree ("razorpay_order_id");
--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "uq_subscription_payments_razorpay_payment_id" ON "subscription_payments" USING btree ("razorpay_payment_id") WHERE "razorpay_payment_id" IS NOT NULL;
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_subscription_payments_business_id" ON "subscription_payments" USING btree ("business_id");
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_subscription_history_business_id" ON "subscription_history" USING btree ("business_id","created_at");
--> statement-breakpoint
INSERT INTO "subscription_plans" ("plan", "name", "price", "duration_days", "is_active")
VALUES
  ('no_plan', 'No Plan', 0, 0, true),
  ('gold', 'Gold', 3046.0000, 365, true),
  ('platinum', 'Platinum', 7742.0000, 365, true)
ON CONFLICT ("plan") DO NOTHING;
