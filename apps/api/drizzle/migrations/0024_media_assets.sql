CREATE TABLE "media_assets" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"storage_key" text NOT NULL,
	"bucket" text NOT NULL,
	"purpose" text NOT NULL,
	"visibility" text NOT NULL,
	"mime_type" text NOT NULL,
	"file_size" bigint NOT NULL,
	"etag" text,
	"checksum" text,
	"owner_type" text,
	"owner_id" uuid,
	"status" text DEFAULT 'pending' NOT NULL,
	"uploaded_by" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL
);--> statement-breakpoint
ALTER TABLE "media_assets" ADD CONSTRAINT "media_assets_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "media_assets" ADD CONSTRAINT "media_assets_uploaded_by_accounts_id_fk" FOREIGN KEY ("uploaded_by") REFERENCES "public"."accounts"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "uq_media_assets_storage_key" ON "media_assets" USING btree ("storage_key");--> statement-breakpoint
CREATE INDEX "idx_media_assets_business" ON "media_assets" USING btree ("business_id");--> statement-breakpoint
CREATE INDEX "idx_media_assets_owner" ON "media_assets" USING btree ("owner_type","owner_id");--> statement-breakpoint
CREATE INDEX "idx_media_assets_purpose" ON "media_assets" USING btree ("business_id","purpose");
