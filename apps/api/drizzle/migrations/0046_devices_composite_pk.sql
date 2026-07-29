-- Allow the same device_id to register for multiple businesses (composite PK).
ALTER TABLE "devices" DROP CONSTRAINT "devices_pkey";--> statement-breakpoint
ALTER TABLE "devices" ADD CONSTRAINT "devices_pkey" PRIMARY KEY ("business_id", "id");
