-- parties.unrecovered_amount is in the Drizzle schema and used by payment shortfall
-- handling, but was missing from some environments (migration 0000 assumed it existed;
-- 0004 only added the CHECK constraint).
ALTER TABLE "parties"
  ADD COLUMN IF NOT EXISTS "unrecovered_amount" numeric(18, 4) DEFAULT '0' NOT NULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'parties_unrecovered_amount_check'
  ) THEN
    ALTER TABLE "parties"
      ADD CONSTRAINT "parties_unrecovered_amount_check"
      CHECK ("unrecovered_amount" >= 0);
  END IF;
END $$;
