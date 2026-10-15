DO $$ BEGIN
 CREATE TYPE "public"."party_contact_import_status" AS ENUM('pending', 'opened', 'submitted', 'completed', 'expired', 'cancelled');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

CREATE TABLE IF NOT EXISTS "party_contact_import_sessions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_by_account_id" uuid NOT NULL,
	"token" text NOT NULL,
	"status" "party_contact_import_status" DEFAULT 'pending' NOT NULL,
	"expires_at" timestamp with time zone NOT NULL,
	"opened_at" timestamp with time zone,
	"submitted_at" timestamp with time zone,
	"completed_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE IF NOT EXISTS "party_contact_import_staging_rows" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"session_id" uuid NOT NULL,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"display_name" text NOT NULL,
	"primary_phone" text NOT NULL,
	"phones" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"email" text,
	"address" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE "party_contact_import_sessions" ADD CONSTRAINT "party_contact_import_sessions_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;
ALTER TABLE "party_contact_import_sessions" ADD CONSTRAINT "party_contact_import_sessions_created_by_account_id_accounts_id_fk" FOREIGN KEY ("created_by_account_id") REFERENCES "public"."accounts"("id") ON DELETE no action ON UPDATE no action;
ALTER TABLE "party_contact_import_staging_rows" ADD CONSTRAINT "party_contact_import_staging_rows_session_id_party_contact_import_sessions_id_fk" FOREIGN KEY ("session_id") REFERENCES "public"."party_contact_import_sessions"("id") ON DELETE cascade ON UPDATE no action;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_party_contact_import_sessions_token" ON "party_contact_import_sessions" USING btree ("token");
CREATE INDEX IF NOT EXISTS "idx_party_contact_import_sessions_business" ON "party_contact_import_sessions" USING btree ("business_id");
CREATE INDEX IF NOT EXISTS "idx_party_contact_import_sessions_status" ON "party_contact_import_sessions" USING btree ("business_id","status");
CREATE UNIQUE INDEX IF NOT EXISTS "uq_party_contact_import_staging_row" ON "party_contact_import_staging_rows" USING btree ("session_id","display_name","primary_phone");
CREATE INDEX IF NOT EXISTS "idx_party_contact_import_staging_session" ON "party_contact_import_staging_rows" USING btree ("session_id");
