ALTER TABLE "payments" ADD COLUMN "discount_amount" money DEFAULT '0' NOT NULL;--> statement-breakpoint
ALTER TABLE "expenses" ADD COLUMN "source_reference_id" uuid;--> statement-breakpoint
ALTER TABLE "expenses" ADD COLUMN "source_reference_type" text;--> statement-breakpoint
ALTER TABLE "expenses" ADD COLUMN "loyalty_points" money;--> statement-breakpoint
ALTER TABLE "expenses" ADD COLUMN "due_date" date;--> statement-breakpoint
ALTER TABLE "expenses" ADD COLUMN "balance_due" money DEFAULT '0';--> statement-breakpoint
CREATE UNIQUE INDEX "uq_expenses_business_source_reference" ON "expenses" USING btree ("business_id","source_reference_id","source_reference_type") WHERE "expenses"."is_deleted" = false AND "expenses"."source_reference_id" IS NOT NULL AND "expenses"."source_reference_type" IS NOT NULL;
