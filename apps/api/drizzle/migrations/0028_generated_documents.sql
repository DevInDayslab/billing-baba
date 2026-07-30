-- Phase 7: cached generated documents (PDF, CSV, Excel) in object storage

CREATE TYPE "generated_document_kind" AS ENUM (
  'invoice_pdf',
  'estimate_pdf',
  'receipt_pdf',
  'delivery_challan_pdf',
  'purchase_pdf',
  'report_pdf',
  'excel',
  'csv'
);

CREATE TYPE "generated_document_source_type" AS ENUM (
  'sale_document',
  'purchase_document',
  'payment',
  'report'
);

CREATE TABLE "generated_documents" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "business_id" uuid NOT NULL,
  "document_kind" "generated_document_kind" NOT NULL,
  "source_type" "generated_document_source_type" NOT NULL,
  "source_id" uuid NOT NULL,
  "media_asset_id" uuid,
  "source_version" integer NOT NULL,
  "file_name" text NOT NULL,
  "mime_type" text NOT NULL,
  "public_token" text NOT NULL,
  "generated_at" timestamp with time zone DEFAULT now() NOT NULL,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  "updated_at" timestamp with time zone DEFAULT now() NOT NULL,
  "deleted_at" timestamp with time zone,
  "is_deleted" boolean DEFAULT false NOT NULL,
  "created_by" uuid,
  "updated_by" uuid,
  "sync_version" integer DEFAULT 1 NOT NULL,
  "device_id" uuid
);

ALTER TABLE "generated_documents"
  ADD CONSTRAINT "generated_documents_business_id_businesses_id_fk"
  FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;

CREATE UNIQUE INDEX "uq_generated_documents_public_token"
  ON "generated_documents" ("public_token");

CREATE UNIQUE INDEX "uq_generated_documents_source"
  ON "generated_documents" ("business_id", "document_kind", "source_type", "source_id")
  WHERE "is_deleted" = false;

CREATE INDEX "idx_generated_documents_source"
  ON "generated_documents" ("business_id", "source_type", "source_id")
  WHERE "is_deleted" = false;
