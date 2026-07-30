CREATE TABLE IF NOT EXISTS "sync_command_acks" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "business_id" uuid NOT NULL,
  "command_id" uuid NOT NULL,
  "command" text NOT NULL,
  "request_hash" text NOT NULL,
  "result_json" jsonb NOT NULL,
  "device_id" uuid,
  "processed_at" timestamp with time zone DEFAULT now() NOT NULL,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "sync_command_acks" ADD CONSTRAINT "sync_command_acks_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "uq_sync_command_acks_business_command" ON "sync_command_acks" USING btree ("business_id","command_id");
