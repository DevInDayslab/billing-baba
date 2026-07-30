-- Company UPI VPA for dynamic Scan-to-Pay QR generation
ALTER TABLE "businesses" ADD COLUMN IF NOT EXISTS "upi_id" text;
