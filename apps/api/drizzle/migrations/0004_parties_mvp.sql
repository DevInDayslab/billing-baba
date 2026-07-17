ALTER TABLE "parties" ADD COLUMN IF NOT EXISTS "is_active" boolean DEFAULT true NOT NULL;--> statement-breakpoint
ALTER TABLE "parties" ADD CONSTRAINT "parties_credit_limit_check" CHECK ("credit_limit" >= 0);--> statement-breakpoint
ALTER TABLE "parties" ADD CONSTRAINT "parties_unrecovered_amount_check" CHECK ("unrecovered_amount" >= 0);--> statement-breakpoint
CREATE INDEX "idx_parties_business_name" ON "parties" USING btree ("business_id","name") WHERE "parties"."is_deleted" = false;--> statement-breakpoint
CREATE INDEX "idx_parties_business_gstin" ON "parties" USING btree ("business_id","gstin") WHERE "parties"."is_deleted" = false AND "parties"."gstin" IS NOT NULL;
