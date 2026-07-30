-- Party enhancements: legal name, alias, party group, area code, additional phones

ALTER TABLE "parties" ADD COLUMN IF NOT EXISTS "legal_name" text;
--> statement-breakpoint
ALTER TABLE "parties" ADD COLUMN IF NOT EXISTS "alias" text;
--> statement-breakpoint
ALTER TABLE "parties" ADD COLUMN IF NOT EXISTS "party_group" text;
--> statement-breakpoint
ALTER TABLE "parties" ADD COLUMN IF NOT EXISTS "area_code" text;
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "party_phones" (
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
	"party_id" uuid NOT NULL,
	"mobile" text NOT NULL,
	"label" text,
	"sort_order" integer DEFAULT 0 NOT NULL
);
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "party_phones" ADD CONSTRAINT "party_phones_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "party_phones" ADD CONSTRAINT "party_phones_party_id_parties_id_fk" FOREIGN KEY ("party_id") REFERENCES "public"."parties"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "uq_party_phones_business_mobile_active" ON "party_phones" ("business_id","mobile") WHERE "party_phones"."is_deleted" = false;
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "idx_party_phones_party" ON "party_phones" ("business_id","party_id") WHERE "party_phones"."is_deleted" = false;
