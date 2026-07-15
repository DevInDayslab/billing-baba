CREATE TYPE "public"."contact_activity_type" AS ENUM('call', 'email', 'meeting', 'note', 'status_change');--> statement-breakpoint
CREATE TABLE "contacts" (
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
	"first_name" text,
	"last_name" text,
	"salutation" text,
	"account_name" text,
	"phone" text,
	"email" text,
	"assigned_to" text,
	"title" text,
	"description" text
);--> statement-breakpoint
CREATE TABLE "contact_activities" (
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
	"contact_id" uuid NOT NULL,
	"type" "contact_activity_type" NOT NULL,
	"notes" text,
	"added_by" text
);--> statement-breakpoint
ALTER TABLE "contacts" ADD CONSTRAINT "contacts_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "contact_activities" ADD CONSTRAINT "contact_activities_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "contact_activities" ADD CONSTRAINT "contact_activities_contact_id_contacts_id_fk" FOREIGN KEY ("contact_id") REFERENCES "public"."contacts"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "idx_contacts_business_name" ON "contacts" USING btree ("business_id","name") WHERE "contacts"."is_deleted" = false;--> statement-breakpoint
CREATE INDEX "idx_contacts_business_account" ON "contacts" USING btree ("business_id","account_name") WHERE "contacts"."is_deleted" = false;--> statement-breakpoint
CREATE INDEX "idx_contact_activities_contact" ON "contact_activities" USING btree ("business_id","contact_id") WHERE "contact_activities"."is_deleted" = false;
