CREATE TABLE "invoice_share_tokens" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"token" text NOT NULL,
	"invoice_id" uuid NOT NULL,
	"business_id" uuid NOT NULL,
	"expires_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"created_by" uuid
);--> statement-breakpoint
ALTER TABLE "invoice_share_tokens" ADD CONSTRAINT "invoice_share_tokens_invoice_id_sales_documents_id_fk" FOREIGN KEY ("invoice_id") REFERENCES "public"."sales_documents"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "invoice_share_tokens" ADD CONSTRAINT "invoice_share_tokens_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "invoice_share_tokens" ADD CONSTRAINT "invoice_share_tokens_created_by_accounts_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."accounts"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "uq_invoice_share_tokens_token" ON "invoice_share_tokens" USING btree ("token");--> statement-breakpoint
CREATE INDEX "idx_invoice_share_tokens_invoice" ON "invoice_share_tokens" USING btree ("invoice_id");--> statement-breakpoint
CREATE INDEX "idx_invoice_share_tokens_business" ON "invoice_share_tokens" USING btree ("business_id");
