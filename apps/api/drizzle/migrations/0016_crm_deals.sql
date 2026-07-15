CREATE TYPE "public"."deal_stage" AS ENUM('qualification', 'needs_analysis', 'value_proposition', 'identify_decision_makers', 'proposal_price_quote', 'negotiation_review', 'closed_won', 'closed_lost', 'closed_lost_to_competition');--> statement-breakpoint
CREATE TABLE "deals" (
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
	"stage" "deal_stage" DEFAULT 'qualification' NOT NULL,
	"account_name" text,
	"assigned_to" text,
	"amount" numeric DEFAULT '0' NOT NULL,
	"expected_close_date" date,
	"description" text
);--> statement-breakpoint
ALTER TABLE "deals" ADD CONSTRAINT "deals_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "idx_deals_business_stage" ON "deals" USING btree ("business_id","stage") WHERE "deals"."is_deleted" = false;--> statement-breakpoint
CREATE INDEX "idx_deals_business_name" ON "deals" USING btree ("business_id","name") WHERE "deals"."is_deleted" = false;
