-- Support revocation of public invoice share tokens
ALTER TABLE "invoice_share_tokens" ADD COLUMN IF NOT EXISTS "revoked_at" timestamptz;

CREATE INDEX IF NOT EXISTS "idx_invoice_share_tokens_active"
  ON "invoice_share_tokens" ("invoice_id", "business_id")
  WHERE "revoked_at" IS NULL;
