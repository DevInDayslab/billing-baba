-- Allow the same device_id to register for multiple businesses (composite PK).
-- Idempotent for DBs that already applied this change out-of-band.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conrelid = 'public.devices'::regclass
      AND contype = 'p'
      AND pg_get_constraintdef(oid) = 'PRIMARY KEY (id)'
  ) THEN
    ALTER TABLE "devices" DROP CONSTRAINT "devices_pkey";
    ALTER TABLE "devices" ADD CONSTRAINT "devices_pkey" PRIMARY KEY ("business_id", "id");
  END IF;
END $$;
