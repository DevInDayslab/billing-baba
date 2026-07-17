DO $$ BEGIN
  CREATE TYPE "payment_source" AS ENUM('manual', 'document_finalize');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
ALTER TABLE "payments" ADD COLUMN IF NOT EXISTS "source" "payment_source" NOT NULL DEFAULT 'manual';
