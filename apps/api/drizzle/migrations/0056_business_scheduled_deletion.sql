ALTER TABLE "businesses"
  ADD COLUMN IF NOT EXISTS "deletion_requested_at" timestamptz,
  ADD COLUMN IF NOT EXISTS "scheduled_deletion_at" timestamptz;
