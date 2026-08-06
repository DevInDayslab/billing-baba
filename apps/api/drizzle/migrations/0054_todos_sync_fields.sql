ALTER TABLE "todos" ADD COLUMN IF NOT EXISTS "is_pinned" boolean DEFAULT false NOT NULL;--> statement-breakpoint
ALTER TABLE "todos" ADD COLUMN IF NOT EXISTS "category" text;--> statement-breakpoint
ALTER TABLE "todos" ADD COLUMN IF NOT EXISTS "reminder_at" timestamp with time zone;--> statement-breakpoint
ALTER TABLE "todos" ADD COLUMN IF NOT EXISTS "linked_invoice_id" uuid;--> statement-breakpoint
ALTER TABLE "todos" ADD COLUMN IF NOT EXISTS "linked_purchase_id" uuid;--> statement-breakpoint
ALTER TABLE "todos" ADD COLUMN IF NOT EXISTS "linked_product_id" uuid;--> statement-breakpoint
ALTER TABLE "todos" ADD COLUMN IF NOT EXISTS "attachment_ids" jsonb DEFAULT '[]'::jsonb NOT NULL;--> statement-breakpoint
DO $$ BEGIN
  IF to_regclass('public.todos') IS NOT NULL THEN
    CREATE INDEX IF NOT EXISTS "idx_todos_sync_pull" ON "todos" USING btree ("business_id","updated_at") WHERE "todos"."is_deleted" = false;
  END IF;
END $$;
