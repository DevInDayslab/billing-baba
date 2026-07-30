CREATE TABLE "notification_send_log" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"idempotency_key" text NOT NULL,
	"notification_type" text NOT NULL,
	"provider" text NOT NULL,
	"recipient_masked" text NOT NULL,
	"company_id" uuid,
	"status" text NOT NULL,
	"provider_message_id" text,
	"error_code" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);--> statement-breakpoint
ALTER TABLE "notification_send_log" ADD CONSTRAINT "notification_send_log_company_id_businesses_id_fk" FOREIGN KEY ("company_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "uq_notification_send_log_idempotency_key" ON "notification_send_log" USING btree ("idempotency_key");--> statement-breakpoint
CREATE INDEX "idx_notification_send_log_created_at" ON "notification_send_log" USING btree ("created_at");--> statement-breakpoint
CREATE INDEX "idx_notification_send_log_company" ON "notification_send_log" USING btree ("company_id");
