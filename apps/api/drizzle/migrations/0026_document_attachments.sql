-- Phase 6: polymorphic document attachments for transactions

CREATE TYPE "document_attachment_entity_type" AS ENUM (
  'sale',
  'purchase',
  'estimate',
  'sale_order',
  'purchase_order',
  'delivery_challan',
  'payment_in',
  'payment_out',
  'expense',
  'job_work'
);

CREATE TYPE "document_attachment_kind" AS ENUM ('image', 'pdf', 'document');

CREATE TABLE "document_attachments" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "business_id" uuid NOT NULL,
  "entity_type" "document_attachment_entity_type" NOT NULL,
  "entity_id" uuid NOT NULL,
  "media_asset_id" uuid,
  "file_name" text NOT NULL,
  "file_url" text,
  "mime_type" text NOT NULL,
  "attachment_kind" "document_attachment_kind" NOT NULL,
  "sort_order" integer DEFAULT 0 NOT NULL,
  "label" text,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  "updated_at" timestamp with time zone DEFAULT now() NOT NULL,
  "deleted_at" timestamp with time zone,
  "is_deleted" boolean DEFAULT false NOT NULL,
  "created_by" uuid,
  "updated_by" uuid,
  "sync_version" integer DEFAULT 1 NOT NULL,
  "device_id" uuid
);

ALTER TABLE "document_attachments"
  ADD CONSTRAINT "document_attachments_business_id_businesses_id_fk"
  FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;

CREATE INDEX "idx_document_attachments_entity"
  ON "document_attachments" ("business_id", "entity_type", "entity_id")
  WHERE "is_deleted" = false;

CREATE INDEX "idx_document_attachments_media_asset"
  ON "document_attachments" ("media_asset_id");
