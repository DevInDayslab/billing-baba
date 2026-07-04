ALTER TABLE "unit_definitions" RENAME COLUMN "full_name" TO "name";--> statement-breakpoint
ALTER TABLE "unit_definitions" ADD COLUMN "symbol" text;--> statement-breakpoint
ALTER TABLE "unit_definitions" ADD COLUMN "decimal_places" integer DEFAULT 0 NOT NULL;--> statement-breakpoint
ALTER TABLE "unit_definitions" ADD COLUMN "is_system" boolean DEFAULT false NOT NULL;--> statement-breakpoint
ALTER TABLE "unit_definitions" ADD COLUMN "is_active" boolean DEFAULT true NOT NULL;--> statement-breakpoint
DROP INDEX IF EXISTS "uq_unit_definitions_business_full_name_active";--> statement-breakpoint
CREATE UNIQUE INDEX "uq_unit_definitions_business_name_active" ON "unit_definitions" USING btree ("business_id",lower("name")) WHERE "unit_definitions"."is_deleted" = false;--> statement-breakpoint
ALTER TABLE "unit_conversions" RENAME COLUMN "base_unit_id" TO "from_unit_id";--> statement-breakpoint
ALTER TABLE "unit_conversions" RENAME COLUMN "secondary_unit_id" TO "to_unit_id";--> statement-breakpoint
DROP INDEX IF EXISTS "uq_unit_conversions_business_pair_active";--> statement-breakpoint
CREATE UNIQUE INDEX "uq_unit_conversions_business_pair_active" ON "unit_conversions" USING btree ("business_id","from_unit_id","to_unit_id") WHERE "unit_conversions"."is_deleted" = false;
