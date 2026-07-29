-- Repair: CRM leads/contacts tables were marked migrated but missing in some DBs.
-- Sync pull queries these entity types and 500s when the relations don't exist.

DO $$ BEGIN
  CREATE TYPE "public"."lead_source" AS ENUM('google_ads', 'referral', 'website', 'walk_in', 'other');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE "public"."lead_status" AS ENUM('new', 'contacted', 'qualified', 'converted', 'lost');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE "public"."lead_activity_type" AS ENUM('call', 'email', 'meeting', 'note', 'status_change');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE "public"."contact_activity_type" AS ENUM('call', 'email', 'meeting', 'note', 'status_change');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS "leads" (
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
);

CREATE TABLE IF NOT EXISTS "lead_activities" (
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
);

CREATE TABLE IF NOT EXISTS "contacts" (
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
);

CREATE TABLE IF NOT EXISTS "contact_activities" (
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
);

DO $$ BEGIN
  ALTER TABLE "leads" ADD CONSTRAINT "leads_business_id_businesses_id_fk"
    FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  ALTER TABLE "lead_activities" ADD CONSTRAINT "lead_activities_business_id_businesses_id_fk"
    FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  ALTER TABLE "lead_activities" ADD CONSTRAINT "lead_activities_lead_id_leads_id_fk"
    FOREIGN KEY ("lead_id") REFERENCES "public"."leads"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  ALTER TABLE "contacts" ADD CONSTRAINT "contacts_business_id_businesses_id_fk"
    FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  ALTER TABLE "contact_activities" ADD CONSTRAINT "contact_activities_business_id_businesses_id_fk"
    FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  ALTER TABLE "contact_activities" ADD CONSTRAINT "contact_activities_contact_id_contacts_id_fk"
    FOREIGN KEY ("contact_id") REFERENCES "public"."contacts"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE INDEX IF NOT EXISTS "idx_leads_business_name" ON "leads" USING btree ("business_id","name") WHERE "leads"."is_deleted" = false;
CREATE INDEX IF NOT EXISTS "idx_leads_business_status" ON "leads" USING btree ("business_id","status") WHERE "leads"."is_deleted" = false;
CREATE INDEX IF NOT EXISTS "idx_lead_activities_lead" ON "lead_activities" USING btree ("business_id","lead_id") WHERE "lead_activities"."is_deleted" = false;
CREATE INDEX IF NOT EXISTS "idx_contacts_business_name" ON "contacts" USING btree ("business_id","name") WHERE "contacts"."is_deleted" = false;
CREATE INDEX IF NOT EXISTS "idx_contacts_business_account" ON "contacts" USING btree ("business_id","account_name") WHERE "contacts"."is_deleted" = false;
CREATE INDEX IF NOT EXISTS "idx_contact_activities_contact" ON "contact_activities" USING btree ("business_id","contact_id") WHERE "contact_activities"."is_deleted" = false;

-- Sync pull indexes (same guards as 0047).
CREATE INDEX IF NOT EXISTS "idx_leads_sync_pull" ON "leads" USING btree ("business_id","updated_at") WHERE "leads"."is_deleted" = false;
CREATE INDEX IF NOT EXISTS "idx_lead_activities_sync_pull" ON "lead_activities" USING btree ("business_id","updated_at") WHERE "lead_activities"."is_deleted" = false;
CREATE INDEX IF NOT EXISTS "idx_contacts_sync_pull" ON "contacts" USING btree ("business_id","updated_at") WHERE "contacts"."is_deleted" = false;
CREATE INDEX IF NOT EXISTS "idx_contact_activities_sync_pull" ON "contact_activities" USING btree ("business_id","updated_at") WHERE "contact_activities"."is_deleted" = false;
