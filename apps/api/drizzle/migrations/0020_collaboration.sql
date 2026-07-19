CREATE TYPE "public"."collaboration_role" AS ENUM('secondary_admin', 'salesman', 'biller', 'biller_and_salesman', 'accountant', 'accountant_edit_access', 'stock_keeper');--> statement-breakpoint
CREATE TYPE "public"."company_member_status" AS ENUM('active', 'left', 'removed');--> statement-breakpoint
CREATE TYPE "public"."invitation_status" AS ENUM('pending', 'opened', 'accepted', 'rejected', 'left', 'expired', 'cancelled');--> statement-breakpoint
CREATE TABLE "company_members" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"company_id" uuid NOT NULL,
	"account_id" uuid NOT NULL,
	"role" "collaboration_role" NOT NULL,
	"status" "company_member_status" DEFAULT 'active' NOT NULL,
	"joined_at" timestamp with time zone,
	"left_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);--> statement-breakpoint
CREATE TABLE "invitations" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"company_id" uuid NOT NULL,
	"invitee_name" text NOT NULL,
	"phone" text,
	"email" text,
	"role" "collaboration_role" NOT NULL,
	"status" "invitation_status" DEFAULT 'pending' NOT NULL,
	"token" text NOT NULL,
	"placeholder_member_id" uuid DEFAULT gen_random_uuid() NOT NULL,
	"created_by" uuid NOT NULL,
	"opened_at" timestamp with time zone,
	"accepted_at" timestamp with time zone,
	"rejected_at" timestamp with time zone,
	"expires_at" timestamp with time zone NOT NULL,
	"superseded_by" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "invitations_phone_or_email" CHECK ("phone" IS NOT NULL OR "email" IS NOT NULL)
);--> statement-breakpoint
ALTER TABLE "company_members" ADD CONSTRAINT "company_members_company_id_businesses_id_fk" FOREIGN KEY ("company_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "company_members" ADD CONSTRAINT "company_members_account_id_accounts_id_fk" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "invitations" ADD CONSTRAINT "invitations_company_id_businesses_id_fk" FOREIGN KEY ("company_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "invitations" ADD CONSTRAINT "invitations_created_by_accounts_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."accounts"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "uq_company_members_active" ON "company_members" USING btree ("company_id","account_id") WHERE "company_members"."status" = 'active';--> statement-breakpoint
CREATE INDEX "idx_company_members_account" ON "company_members" USING btree ("account_id");--> statement-breakpoint
CREATE INDEX "idx_company_members_company_status" ON "company_members" USING btree ("company_id","status");--> statement-breakpoint
CREATE UNIQUE INDEX "uq_invitations_token" ON "invitations" USING btree ("token");--> statement-breakpoint
CREATE UNIQUE INDEX "uq_invitations_company_phone_active" ON "invitations" USING btree ("company_id","phone") WHERE "invitations"."phone" IS NOT NULL AND "invitations"."status" IN ('pending', 'opened');--> statement-breakpoint
CREATE INDEX "idx_invitations_company" ON "invitations" USING btree ("company_id");--> statement-breakpoint
CREATE INDEX "idx_invitations_phone" ON "invitations" USING btree ("phone");--> statement-breakpoint
CREATE INDEX "idx_invitations_email" ON "invitations" USING btree ("email");
