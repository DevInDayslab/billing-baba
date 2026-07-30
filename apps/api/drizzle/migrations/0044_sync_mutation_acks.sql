CREATE TABLE IF NOT EXISTS "sync_mutation_acks" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "business_id" uuid NOT NULL,
  "mutation_id" uuid NOT NULL,
  "kind" text NOT NULL,
  "result_json" jsonb NOT NULL,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "sync_mutation_acks" ADD CONSTRAINT "sync_mutation_acks_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "uq_sync_mutation_acks_business_mutation" ON "sync_mutation_acks" USING btree ("business_id","mutation_id");
