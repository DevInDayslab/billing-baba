CREATE TABLE "item_alternatives" (
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
	"item_id" uuid NOT NULL,
	"alternative_item_id" uuid NOT NULL,
	"sort_order" integer DEFAULT 0 NOT NULL
);
--> statement-breakpoint
ALTER TABLE "item_alternatives" ADD CONSTRAINT "item_alternatives_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "item_alternatives" ADD CONSTRAINT "item_alternatives_item_id_items_id_fk" FOREIGN KEY ("item_id") REFERENCES "public"."items"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "item_alternatives" ADD CONSTRAINT "item_alternatives_alternative_item_id_items_id_fk" FOREIGN KEY ("alternative_item_id") REFERENCES "public"."items"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "uq_item_alternatives_active" ON "item_alternatives" USING btree ("business_id","item_id","alternative_item_id") WHERE "item_alternatives"."is_deleted" = false;--> statement-breakpoint
CREATE INDEX "idx_item_alternatives_item" ON "item_alternatives" USING btree ("business_id","item_id") WHERE "item_alternatives"."is_deleted" = false;
