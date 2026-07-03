ALTER TABLE "accounts" ADD COLUMN IF NOT EXISTS "email" text;
ALTER TABLE "accounts" ADD COLUMN IF NOT EXISTS "avatar_url" text;
ALTER TABLE "accounts" ADD COLUMN IF NOT EXISTS "timezone" text DEFAULT 'Asia/Kolkata' NOT NULL;
ALTER TABLE "accounts" ADD COLUMN IF NOT EXISTS "language" text DEFAULT 'en' NOT NULL;
