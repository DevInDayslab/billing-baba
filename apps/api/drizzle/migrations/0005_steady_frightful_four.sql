CREATE TABLE "unit_conversions" (
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
	"base_unit_id" uuid NOT NULL,
	"secondary_unit_id" uuid NOT NULL,
	"conversion_factor" numeric(18, 4) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "unit_definitions" (
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
	"full_name" text NOT NULL,
	"short_name" text NOT NULL
);
--> statement-breakpoint
ALTER TABLE "businesses" ADD COLUMN "business_type" text;--> statement-breakpoint
ALTER TABLE "businesses" ADD COLUMN "business_category" text;--> statement-breakpoint
ALTER TABLE "businesses" ADD COLUMN "pincode" text;--> statement-breakpoint
ALTER TABLE "businesses" ADD COLUMN "currency" text DEFAULT 'INR' NOT NULL;--> statement-breakpoint
ALTER TABLE "businesses" ADD COLUMN "timezone" text DEFAULT 'Asia/Kolkata' NOT NULL;--> statement-breakpoint
ALTER TABLE "businesses" ADD COLUMN "language" text DEFAULT 'en' NOT NULL;--> statement-breakpoint
ALTER TABLE "businesses" ADD COLUMN "logo_url" text;--> statement-breakpoint
ALTER TABLE "businesses" ADD COLUMN "signature_url" text;--> statement-breakpoint
ALTER TABLE "parties" ADD COLUMN "is_active" boolean DEFAULT true NOT NULL;--> statement-breakpoint
ALTER TABLE "accounts" ADD COLUMN "email" text;--> statement-breakpoint
ALTER TABLE "accounts" ADD COLUMN "avatar_url" text;--> statement-breakpoint
ALTER TABLE "accounts" ADD COLUMN "timezone" text DEFAULT 'Asia/Kolkata' NOT NULL;--> statement-breakpoint
ALTER TABLE "accounts" ADD COLUMN "language" text DEFAULT 'en' NOT NULL;--> statement-breakpoint
ALTER TABLE "unit_conversions" ADD CONSTRAINT "unit_conversions_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "unit_conversions" ADD CONSTRAINT "unit_conversions_base_unit_id_unit_definitions_id_fk" FOREIGN KEY ("base_unit_id") REFERENCES "public"."unit_definitions"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "unit_conversions" ADD CONSTRAINT "unit_conversions_secondary_unit_id_unit_definitions_id_fk" FOREIGN KEY ("secondary_unit_id") REFERENCES "public"."unit_definitions"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "unit_definitions" ADD CONSTRAINT "unit_definitions_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "uq_unit_conversions_business_pair_active" ON "unit_conversions" USING btree ("business_id","base_unit_id","secondary_unit_id") WHERE "unit_conversions"."is_deleted" = false;--> statement-breakpoint
CREATE UNIQUE INDEX "uq_unit_definitions_business_full_name_active" ON "unit_definitions" USING btree ("business_id",lower("full_name")) WHERE "unit_definitions"."is_deleted" = false;--> statement-breakpoint
CREATE UNIQUE INDEX "uq_unit_definitions_business_short_name_active" ON "unit_definitions" USING btree ("business_id",lower("short_name")) WHERE "unit_definitions"."is_deleted" = false;