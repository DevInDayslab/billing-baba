CREATE TYPE "public"."loyalty_transaction_type" AS ENUM('earn', 'redeem');--> statement-breakpoint
CREATE TABLE "loyalty_transactions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"party_id" uuid NOT NULL,
	"transaction_type" "loyalty_transaction_type" NOT NULL,
	"points" numeric(18, 4) NOT NULL,
	"balance_after" numeric(18, 4) NOT NULL,
	"reference_id" uuid,
	"reference_type" text,
	"spend_amount" numeric(18, 4),
	"rupees_per_point" numeric(18, 4),
	"description" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"created_by" uuid,
	CONSTRAINT "loyalty_transactions_points_check" CHECK ("points" > 0),
	CONSTRAINT "loyalty_transactions_balance_after_check" CHECK ("balance_after" >= 0)
);
--> statement-breakpoint
ALTER TABLE "party_loyalty_balances" ADD CONSTRAINT "party_loyalty_balances_points_earned_check" CHECK ("points_earned" >= 0);--> statement-breakpoint
ALTER TABLE "party_loyalty_balances" ADD CONSTRAINT "party_loyalty_balances_points_available_check" CHECK ("points_available" >= 0);--> statement-breakpoint
ALTER TABLE "loyalty_transactions" ADD CONSTRAINT "loyalty_transactions_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "loyalty_transactions" ADD CONSTRAINT "loyalty_transactions_party_id_parties_id_fk" FOREIGN KEY ("party_id") REFERENCES "public"."parties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "idx_loyalty_transactions_party_created" ON "loyalty_transactions" USING btree ("business_id","party_id","created_at");
