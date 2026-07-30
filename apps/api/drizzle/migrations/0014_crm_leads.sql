CREATE TYPE "public"."lead_source" AS ENUM('google_ads', 'referral', 'website', 'walk_in', 'other');--> statement-breakpoint
CREATE TYPE "public"."lead_status" AS ENUM('new', 'contacted', 'qualified', 'converted', 'lost');--> statement-breakpoint
CREATE TYPE "public"."lead_activity_type" AS ENUM('call', 'email', 'meeting', 'note', 'status_change');--> statement-breakpoint
CREATE TABLE "leads" (
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
	"company" text,
	"phone" text,
	"email" text,
	"lead_source" "lead_source",
	"status" "lead_status" DEFAULT 'new' NOT NULL,
	"assigned_to" text,
	"notes" text
);--> statement-breakpoint
CREATE TABLE "lead_activities" (
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
	"lead_id" uuid NOT NULL,
	"type" "lead_activity_type" NOT NULL,
	"notes" text,
	"added_by" text
);--> statement-breakpoint
ALTER TABLE "leads" ADD CONSTRAINT "leads_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "lead_activities" ADD CONSTRAINT "lead_activities_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "lead_activities" ADD CONSTRAINT "lead_activities_lead_id_leads_id_fk" FOREIGN KEY ("lead_id") REFERENCES "public"."leads"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "idx_leads_business_name" ON "leads" USING btree ("business_id","name") WHERE "leads"."is_deleted" = false;--> statement-breakpoint
CREATE INDEX "idx_leads_business_status" ON "leads" USING btree ("business_id","status") WHERE "leads"."is_deleted" = false;--> statement-breakpoint
CREATE INDEX "idx_lead_activities_lead" ON "lead_activities" USING btree ("business_id","lead_id") WHERE "lead_activities"."is_deleted" = false;
