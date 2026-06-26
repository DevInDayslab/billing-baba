CREATE TYPE "public"."alert_type" AS ENUM('payment_overdue', 'low_stock', 'credit_limit', 'price_conflict');--> statement-breakpoint
CREATE TYPE "public"."attendance_status" AS ENUM('present', 'late', 'half_day', 'overtime', 'absent');--> statement-breakpoint
CREATE TYPE "public"."credit_limit_action" AS ENUM('block', 'warn');--> statement-breakpoint
CREATE TYPE "public"."document_status" AS ENUM('draft', 'finalized', 'cancelled', 'converted');--> statement-breakpoint
CREATE TYPE "public"."inventory_movement_type" AS ENUM('opening', 'purchase', 'sale', 'sales_return', 'purchase_return', 'challan', 'adjustment');--> statement-breakpoint
CREATE TYPE "public"."item_type" AS ENUM('product', 'service');--> statement-breakpoint
CREATE TYPE "public"."ledger_entry_type" AS ENUM('sale', 'purchase', 'payment', 'return', 'expense', 'opening');--> statement-breakpoint
CREATE TYPE "public"."online_order_status" AS ENUM('pending', 'accepted', 'rejected', 'completed');--> statement-breakpoint
CREATE TYPE "public"."party_category" AS ENUM('customer', 'retailer', 'wholesaler', 'manufacturer', 'custom');--> statement-breakpoint
CREATE TYPE "public"."party_type" AS ENUM('customer', 'supplier', 'both');--> statement-breakpoint
CREATE TYPE "public"."payment_direction" AS ENUM('received', 'paid');--> statement-breakpoint
CREATE TYPE "public"."payment_mode" AS ENUM('cash', 'upi', 'card', 'cheque', 'bank_transfer', 'other');--> statement-breakpoint
CREATE TYPE "public"."pricing_tier" AS ENUM('tier_1', 'tier_2', 'tier_3');--> statement-breakpoint
CREATE TYPE "public"."purchase_document_type" AS ENUM('purchase_order', 'purchase_bill', 'purchase_return');--> statement-breakpoint
CREATE TYPE "public"."sales_document_type" AS ENUM('estimate', 'delivery_challan', 'tax_invoice', 'bill_of_supply', 'normal_invoice', 'pos', 'sales_return');--> statement-breakpoint
CREATE TYPE "public"."short_payment_handling" AS ENUM('official_balance', 'unrecovered');--> statement-breakpoint
CREATE TYPE "public"."tax_type" AS ENUM('cgst_sgst', 'igst', 'exempt', 'none');--> statement-breakpoint
CREATE TYPE "public"."todo_priority" AS ENUM('low', 'medium', 'high');--> statement-breakpoint
CREATE TYPE "public"."user_role" AS ENUM('owner', 'manager', 'staff');--> statement-breakpoint
CREATE TYPE "public"."valuation_method" AS ENUM('fifo', 'average');--> statement-breakpoint
CREATE TYPE "public"."visit_purpose" AS ENUM('purchase', 'inquiry', 'payment_collection', 'casual');--> statement-breakpoint
CREATE TABLE "branches" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"name" text NOT NULL,
	"address" text,
	"is_default" boolean DEFAULT false NOT NULL
);
--> statement-breakpoint
CREATE TABLE "businesses" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"name" text NOT NULL,
	"gstin" text,
	"state_code" text NOT NULL,
	"address" text,
	"phone" text,
	"email" text,
	"valuation_method" "valuation_method" DEFAULT 'average' NOT NULL
);
--> statement-breakpoint
CREATE TABLE "areas" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"name" text NOT NULL
);
--> statement-breakpoint
CREATE TABLE "business_settings" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"valuation_method" "valuation_method" DEFAULT 'average' NOT NULL,
	"default_tax_type" "tax_type" DEFAULT 'none' NOT NULL,
	"invoice_terms" text,
	"enable_price_conflict_alerts" boolean DEFAULT true NOT NULL,
	"credit_limit_action" "credit_limit_action" DEFAULT 'warn' NOT NULL
);
--> statement-breakpoint
CREATE TABLE "document_number_sequences" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"document_series" text NOT NULL,
	"prefix" text,
	"next_number" integer DEFAULT 1 NOT NULL,
	"fiscal_year" text NOT NULL
);
--> statement-breakpoint
CREATE TABLE "loyalty_rules" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"rupees_per_point" numeric(18, 4) NOT NULL,
	"is_active" boolean DEFAULT true NOT NULL
);
--> statement-breakpoint
CREATE TABLE "tax_rates" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"name" text NOT NULL,
	"rate" numeric(18, 4) NOT NULL,
	"is_default" boolean DEFAULT false NOT NULL
);
--> statement-breakpoint
CREATE TABLE "attendance_records" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"user_id" uuid NOT NULL,
	"clock_in_at" timestamp with time zone NOT NULL,
	"clock_out_at" timestamp with time zone,
	"status" "attendance_status" DEFAULT 'present' NOT NULL,
	"notes" text
);
--> statement-breakpoint
CREATE TABLE "devices" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"user_id" uuid,
	"device_name" text NOT NULL,
	"platform" text NOT NULL,
	"last_sync_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE "refresh_tokens" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"token_hash" text NOT NULL,
	"expires_at" timestamp with time zone NOT NULL,
	"revoked_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"name" text NOT NULL,
	"email" text,
	"phone" text,
	"password_hash" text NOT NULL,
	"role" "user_role" DEFAULT 'staff' NOT NULL,
	"is_active" boolean DEFAULT true NOT NULL,
	CONSTRAINT "users_email_or_phone" CHECK ("users"."email" IS NOT NULL OR "users"."phone" IS NOT NULL)
);
--> statement-breakpoint
CREATE TABLE "parties" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"name" text NOT NULL,
	"mobile" text,
	"email" text,
	"party_type" "party_type" DEFAULT 'customer' NOT NULL,
	"party_category" "party_category",
	"pricing_tier" "pricing_tier" DEFAULT 'tier_1' NOT NULL,
	"gstin" text,
	"state_code" text,
	"area_id" uuid,
	"credit_limit" numeric(18, 4) DEFAULT '0' NOT NULL,
	"opening_balance" numeric(18, 4) DEFAULT '0' NOT NULL,
	"unrecovered_amount" numeric(18, 4) DEFAULT '0' NOT NULL,
	"face_image_url" text,
	"connected_since" date,
	"notes" text
);
--> statement-breakpoint
CREATE TABLE "party_attachments" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"party_id" uuid NOT NULL,
	"file_url" text NOT NULL,
	"file_type" text NOT NULL,
	"label" text
);
--> statement-breakpoint
CREATE TABLE "party_links" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"party_id" uuid NOT NULL,
	"linked_party_id" uuid NOT NULL,
	"link_type" text NOT NULL
);
--> statement-breakpoint
CREATE TABLE "party_loyalty_balances" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"party_id" uuid NOT NULL,
	"points_earned" numeric(18, 4) DEFAULT '0' NOT NULL,
	"points_available" numeric(18, 4) DEFAULT '0' NOT NULL
);
--> statement-breakpoint
CREATE TABLE "party_tag_assignments" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"party_id" uuid NOT NULL,
	"party_tag_id" uuid NOT NULL
);
--> statement-breakpoint
CREATE TABLE "party_tags" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"name" text NOT NULL,
	"color" text
);
--> statement-breakpoint
CREATE TABLE "party_visits" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"party_id" uuid NOT NULL,
	"visit_date" timestamp with time zone NOT NULL,
	"purpose" "visit_purpose" NOT NULL,
	"sale_type" text,
	"notes" text,
	"recorded_by" uuid
);
--> statement-breakpoint
CREATE TABLE "brands" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"name" text NOT NULL
);
--> statement-breakpoint
CREATE TABLE "categories" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"name" text NOT NULL
);
--> statement-breakpoint
CREATE TABLE "godowns" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"name" text NOT NULL,
	"address" text,
	"is_default" boolean DEFAULT false NOT NULL
);
--> statement-breakpoint
CREATE TABLE "inventory_movements" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"item_id" uuid NOT NULL,
	"godown_id" uuid NOT NULL,
	"movement_type" "inventory_movement_type" NOT NULL,
	"quantity_delta" numeric(18, 4) NOT NULL,
	"cost_per_unit" numeric(18, 4),
	"reference_id" uuid,
	"reference_type" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"created_by" uuid
);
--> statement-breakpoint
CREATE TABLE "item_images" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"item_id" uuid NOT NULL,
	"image_url" text NOT NULL,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"is_primary" boolean DEFAULT false NOT NULL
);
--> statement-breakpoint
CREATE TABLE "item_locations" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"item_id" uuid NOT NULL,
	"godown_id" uuid NOT NULL,
	"rack" text,
	"shelf" text,
	"photo_url" text,
	"photo_taken_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE "item_price_history" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"item_id" uuid NOT NULL,
	"price" numeric(18, 4) NOT NULL,
	"pricing_tier" "pricing_tier",
	"changed_by" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "item_tier_prices" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"item_id" uuid NOT NULL,
	"pricing_tier" "pricing_tier" NOT NULL,
	"price" numeric(18, 4) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "item_units" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"item_id" uuid NOT NULL,
	"unit_name" text NOT NULL,
	"conversion_factor" numeric(18, 4) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "items" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"name" text NOT NULL,
	"description" text,
	"item_type" "item_type" DEFAULT 'product' NOT NULL,
	"has_stock_tracking" boolean DEFAULT true NOT NULL,
	"category_id" uuid,
	"brand_id" uuid,
	"hsn_code" text,
	"barcode" text,
	"base_unit" text DEFAULT 'piece' NOT NULL,
	"mrp" numeric(18, 4),
	"is_mrp_only" boolean DEFAULT false NOT NULL,
	"market_price" numeric(18, 4),
	"sale_price" numeric(18, 4) DEFAULT '0' NOT NULL,
	"purchase_price" numeric(18, 4) DEFAULT '0' NOT NULL,
	"reorder_level" numeric(18, 4),
	"primary_image_url" text
);
--> statement-breakpoint
CREATE TABLE "stock_levels" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"item_id" uuid NOT NULL,
	"godown_id" uuid NOT NULL,
	"quantity" numeric(18, 4) DEFAULT '0' NOT NULL,
	"average_cost" numeric(18, 4) DEFAULT '0' NOT NULL,
	"reorder_level" numeric(18, 4)
);
--> statement-breakpoint
CREATE TABLE "pos_sessions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"user_id" uuid NOT NULL,
	"started_at" timestamp with time zone DEFAULT now() NOT NULL,
	"ended_at" timestamp with time zone,
	"opening_cash" numeric(18, 4),
	"closing_cash" numeric(18, 4)
);
--> statement-breakpoint
CREATE TABLE "sales_document_lines" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"sales_document_id" uuid NOT NULL,
	"item_id" uuid NOT NULL,
	"quantity" numeric(18, 4) NOT NULL,
	"unit" text NOT NULL,
	"unit_price" numeric(18, 4) NOT NULL,
	"market_price" numeric(18, 4),
	"discount_amount" numeric(18, 4) DEFAULT '0' NOT NULL,
	"tax_type" "tax_type" DEFAULT 'none' NOT NULL,
	"tax_rate" numeric(18, 4) DEFAULT '0' NOT NULL,
	"cgst_amount" numeric(18, 4) DEFAULT '0' NOT NULL,
	"sgst_amount" numeric(18, 4) DEFAULT '0' NOT NULL,
	"igst_amount" numeric(18, 4) DEFAULT '0' NOT NULL,
	"line_total" numeric(18, 4) NOT NULL,
	"sort_order" integer DEFAULT 0 NOT NULL
);
--> statement-breakpoint
CREATE TABLE "sales_documents" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"document_type" "sales_document_type" NOT NULL,
	"status" "document_status" DEFAULT 'draft' NOT NULL,
	"document_number" text,
	"document_series" text NOT NULL,
	"party_id" uuid,
	"is_gst_formal" boolean DEFAULT false NOT NULL,
	"party_state_code" text,
	"subtotal" numeric(18, 4) DEFAULT '0' NOT NULL,
	"discount_total" numeric(18, 4) DEFAULT '0' NOT NULL,
	"tax_amount" numeric(18, 4) DEFAULT '0' NOT NULL,
	"total_amount" numeric(18, 4) DEFAULT '0' NOT NULL,
	"document_date" timestamp with time zone DEFAULT now() NOT NULL,
	"converted_from_id" uuid,
	"pos_session_id" uuid,
	"notes" text
);
--> statement-breakpoint
CREATE TABLE "expense_categories" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"name" text NOT NULL,
	"is_system" boolean DEFAULT false NOT NULL
);
--> statement-breakpoint
CREATE TABLE "expenses" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"category_id" uuid NOT NULL,
	"party_id" uuid,
	"amount" numeric(18, 4) NOT NULL,
	"description" text,
	"expense_date" date NOT NULL,
	"payment_mode" "payment_mode"
);
--> statement-breakpoint
CREATE TABLE "purchase_document_lines" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"purchase_document_id" uuid NOT NULL,
	"item_id" uuid NOT NULL,
	"quantity" numeric(18, 4) NOT NULL,
	"unit" text NOT NULL,
	"unit_price" numeric(18, 4) NOT NULL,
	"tax_type" "tax_type" DEFAULT 'none' NOT NULL,
	"tax_rate" numeric(18, 4) DEFAULT '0' NOT NULL,
	"line_total" numeric(18, 4) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "purchase_documents" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"document_type" "purchase_document_type" NOT NULL,
	"status" "document_status" DEFAULT 'draft' NOT NULL,
	"document_number" text,
	"document_series" text NOT NULL,
	"party_id" uuid NOT NULL,
	"subtotal" numeric(18, 4) DEFAULT '0' NOT NULL,
	"tax_amount" numeric(18, 4) DEFAULT '0' NOT NULL,
	"total_amount" numeric(18, 4) DEFAULT '0' NOT NULL,
	"document_date" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "ledger_entries" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"party_id" uuid,
	"entry_type" "ledger_entry_type" NOT NULL,
	"debit" numeric(18, 4) DEFAULT '0' NOT NULL,
	"credit" numeric(18, 4) DEFAULT '0' NOT NULL,
	"balance_after" numeric(18, 4) NOT NULL,
	"reference_id" uuid,
	"reference_type" text,
	"entry_date" date NOT NULL,
	"description" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "payment_allocations" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"payment_id" uuid NOT NULL,
	"sales_document_id" uuid,
	"purchase_document_id" uuid,
	"allocated_amount" numeric(18, 4) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "payments" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"party_id" uuid NOT NULL,
	"direction" "payment_direction" NOT NULL,
	"amount" numeric(18, 4) NOT NULL,
	"payment_mode" "payment_mode" NOT NULL,
	"payment_date" timestamp with time zone DEFAULT now() NOT NULL,
	"reference_number" text,
	"notes" text,
	"short_payment_handling" "short_payment_handling"
);
--> statement-breakpoint
CREATE TABLE "alerts" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"alert_type" "alert_type" NOT NULL,
	"title" text NOT NULL,
	"message" text NOT NULL,
	"reference_id" uuid,
	"reference_type" text,
	"is_read" boolean DEFAULT false NOT NULL
);
--> statement-breakpoint
CREATE TABLE "todos" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"title" text NOT NULL,
	"description" text,
	"priority" "todo_priority" DEFAULT 'medium' NOT NULL,
	"party_id" uuid,
	"due_date" date,
	"is_completed" boolean DEFAULT false NOT NULL,
	"completed_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE "online_orders" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"business_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	"is_deleted" boolean DEFAULT false NOT NULL,
	"created_by" uuid,
	"updated_by" uuid,
	"sync_version" integer DEFAULT 1 NOT NULL,
	"device_id" uuid,
	"external_order_id" text NOT NULL,
	"party_id" uuid,
	"status" "online_order_status" DEFAULT 'pending' NOT NULL,
	"total_amount" numeric(18, 4) NOT NULL,
	"order_payload" jsonb NOT NULL,
	"sales_document_id" uuid,
	"received_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "schema_version" (
	"id" integer PRIMARY KEY DEFAULT 1 NOT NULL,
	"version" integer DEFAULT 1 NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "branches" ADD CONSTRAINT "branches_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "areas" ADD CONSTRAINT "areas_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "business_settings" ADD CONSTRAINT "business_settings_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "document_number_sequences" ADD CONSTRAINT "document_number_sequences_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "loyalty_rules" ADD CONSTRAINT "loyalty_rules_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "tax_rates" ADD CONSTRAINT "tax_rates_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "attendance_records" ADD CONSTRAINT "attendance_records_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "attendance_records" ADD CONSTRAINT "attendance_records_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "devices" ADD CONSTRAINT "devices_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "devices" ADD CONSTRAINT "devices_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "refresh_tokens" ADD CONSTRAINT "refresh_tokens_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "users" ADD CONSTRAINT "users_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "parties" ADD CONSTRAINT "parties_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "parties" ADD CONSTRAINT "parties_area_id_areas_id_fk" FOREIGN KEY ("area_id") REFERENCES "public"."areas"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "party_attachments" ADD CONSTRAINT "party_attachments_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "party_attachments" ADD CONSTRAINT "party_attachments_party_id_parties_id_fk" FOREIGN KEY ("party_id") REFERENCES "public"."parties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "party_links" ADD CONSTRAINT "party_links_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "party_links" ADD CONSTRAINT "party_links_party_id_parties_id_fk" FOREIGN KEY ("party_id") REFERENCES "public"."parties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "party_links" ADD CONSTRAINT "party_links_linked_party_id_parties_id_fk" FOREIGN KEY ("linked_party_id") REFERENCES "public"."parties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "party_loyalty_balances" ADD CONSTRAINT "party_loyalty_balances_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "party_loyalty_balances" ADD CONSTRAINT "party_loyalty_balances_party_id_parties_id_fk" FOREIGN KEY ("party_id") REFERENCES "public"."parties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "party_tag_assignments" ADD CONSTRAINT "party_tag_assignments_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "party_tag_assignments" ADD CONSTRAINT "party_tag_assignments_party_id_parties_id_fk" FOREIGN KEY ("party_id") REFERENCES "public"."parties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "party_tag_assignments" ADD CONSTRAINT "party_tag_assignments_party_tag_id_party_tags_id_fk" FOREIGN KEY ("party_tag_id") REFERENCES "public"."party_tags"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "party_tags" ADD CONSTRAINT "party_tags_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "party_visits" ADD CONSTRAINT "party_visits_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "party_visits" ADD CONSTRAINT "party_visits_party_id_parties_id_fk" FOREIGN KEY ("party_id") REFERENCES "public"."parties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "party_visits" ADD CONSTRAINT "party_visits_recorded_by_users_id_fk" FOREIGN KEY ("recorded_by") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "brands" ADD CONSTRAINT "brands_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "categories" ADD CONSTRAINT "categories_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "godowns" ADD CONSTRAINT "godowns_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "inventory_movements" ADD CONSTRAINT "inventory_movements_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "inventory_movements" ADD CONSTRAINT "inventory_movements_item_id_items_id_fk" FOREIGN KEY ("item_id") REFERENCES "public"."items"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "inventory_movements" ADD CONSTRAINT "inventory_movements_godown_id_godowns_id_fk" FOREIGN KEY ("godown_id") REFERENCES "public"."godowns"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "inventory_movements" ADD CONSTRAINT "inventory_movements_created_by_users_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "item_images" ADD CONSTRAINT "item_images_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "item_images" ADD CONSTRAINT "item_images_item_id_items_id_fk" FOREIGN KEY ("item_id") REFERENCES "public"."items"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "item_locations" ADD CONSTRAINT "item_locations_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "item_locations" ADD CONSTRAINT "item_locations_item_id_items_id_fk" FOREIGN KEY ("item_id") REFERENCES "public"."items"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "item_locations" ADD CONSTRAINT "item_locations_godown_id_godowns_id_fk" FOREIGN KEY ("godown_id") REFERENCES "public"."godowns"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "item_price_history" ADD CONSTRAINT "item_price_history_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "item_price_history" ADD CONSTRAINT "item_price_history_item_id_items_id_fk" FOREIGN KEY ("item_id") REFERENCES "public"."items"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "item_price_history" ADD CONSTRAINT "item_price_history_changed_by_users_id_fk" FOREIGN KEY ("changed_by") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "item_tier_prices" ADD CONSTRAINT "item_tier_prices_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "item_tier_prices" ADD CONSTRAINT "item_tier_prices_item_id_items_id_fk" FOREIGN KEY ("item_id") REFERENCES "public"."items"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "item_units" ADD CONSTRAINT "item_units_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "item_units" ADD CONSTRAINT "item_units_item_id_items_id_fk" FOREIGN KEY ("item_id") REFERENCES "public"."items"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "items" ADD CONSTRAINT "items_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "items" ADD CONSTRAINT "items_category_id_categories_id_fk" FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "items" ADD CONSTRAINT "items_brand_id_brands_id_fk" FOREIGN KEY ("brand_id") REFERENCES "public"."brands"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "stock_levels" ADD CONSTRAINT "stock_levels_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "stock_levels" ADD CONSTRAINT "stock_levels_item_id_items_id_fk" FOREIGN KEY ("item_id") REFERENCES "public"."items"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "stock_levels" ADD CONSTRAINT "stock_levels_godown_id_godowns_id_fk" FOREIGN KEY ("godown_id") REFERENCES "public"."godowns"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "pos_sessions" ADD CONSTRAINT "pos_sessions_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "pos_sessions" ADD CONSTRAINT "pos_sessions_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sales_document_lines" ADD CONSTRAINT "sales_document_lines_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sales_document_lines" ADD CONSTRAINT "sales_document_lines_sales_document_id_sales_documents_id_fk" FOREIGN KEY ("sales_document_id") REFERENCES "public"."sales_documents"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sales_document_lines" ADD CONSTRAINT "sales_document_lines_item_id_items_id_fk" FOREIGN KEY ("item_id") REFERENCES "public"."items"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sales_documents" ADD CONSTRAINT "sales_documents_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sales_documents" ADD CONSTRAINT "sales_documents_party_id_parties_id_fk" FOREIGN KEY ("party_id") REFERENCES "public"."parties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sales_documents" ADD CONSTRAINT "sales_documents_converted_from_id_sales_documents_id_fk" FOREIGN KEY ("converted_from_id") REFERENCES "public"."sales_documents"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sales_documents" ADD CONSTRAINT "sales_documents_pos_session_id_pos_sessions_id_fk" FOREIGN KEY ("pos_session_id") REFERENCES "public"."pos_sessions"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "expense_categories" ADD CONSTRAINT "expense_categories_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "expenses" ADD CONSTRAINT "expenses_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "expenses" ADD CONSTRAINT "expenses_category_id_expense_categories_id_fk" FOREIGN KEY ("category_id") REFERENCES "public"."expense_categories"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "expenses" ADD CONSTRAINT "expenses_party_id_parties_id_fk" FOREIGN KEY ("party_id") REFERENCES "public"."parties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "purchase_document_lines" ADD CONSTRAINT "purchase_document_lines_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "purchase_document_lines" ADD CONSTRAINT "purchase_document_lines_purchase_document_id_purchase_documents_id_fk" FOREIGN KEY ("purchase_document_id") REFERENCES "public"."purchase_documents"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "purchase_document_lines" ADD CONSTRAINT "purchase_document_lines_item_id_items_id_fk" FOREIGN KEY ("item_id") REFERENCES "public"."items"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "purchase_documents" ADD CONSTRAINT "purchase_documents_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "purchase_documents" ADD CONSTRAINT "purchase_documents_party_id_parties_id_fk" FOREIGN KEY ("party_id") REFERENCES "public"."parties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "ledger_entries" ADD CONSTRAINT "ledger_entries_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "ledger_entries" ADD CONSTRAINT "ledger_entries_party_id_parties_id_fk" FOREIGN KEY ("party_id") REFERENCES "public"."parties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "payment_allocations" ADD CONSTRAINT "payment_allocations_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "payment_allocations" ADD CONSTRAINT "payment_allocations_payment_id_payments_id_fk" FOREIGN KEY ("payment_id") REFERENCES "public"."payments"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "payment_allocations" ADD CONSTRAINT "payment_allocations_sales_document_id_sales_documents_id_fk" FOREIGN KEY ("sales_document_id") REFERENCES "public"."sales_documents"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "payment_allocations" ADD CONSTRAINT "payment_allocations_purchase_document_id_purchase_documents_id_fk" FOREIGN KEY ("purchase_document_id") REFERENCES "public"."purchase_documents"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "payments" ADD CONSTRAINT "payments_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "payments" ADD CONSTRAINT "payments_party_id_parties_id_fk" FOREIGN KEY ("party_id") REFERENCES "public"."parties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "alerts" ADD CONSTRAINT "alerts_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "todos" ADD CONSTRAINT "todos_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "todos" ADD CONSTRAINT "todos_party_id_parties_id_fk" FOREIGN KEY ("party_id") REFERENCES "public"."parties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "online_orders" ADD CONSTRAINT "online_orders_business_id_businesses_id_fk" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "online_orders" ADD CONSTRAINT "online_orders_party_id_parties_id_fk" FOREIGN KEY ("party_id") REFERENCES "public"."parties"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "online_orders" ADD CONSTRAINT "online_orders_sales_document_id_sales_documents_id_fk" FOREIGN KEY ("sales_document_id") REFERENCES "public"."sales_documents"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "uq_businesses_gstin" ON "businesses" USING btree ("gstin") WHERE "businesses"."gstin" IS NOT NULL;--> statement-breakpoint
CREATE UNIQUE INDEX "uq_document_number_sequences_business_series_year" ON "document_number_sequences" USING btree ("business_id","document_series","fiscal_year");--> statement-breakpoint
CREATE UNIQUE INDEX "uq_users_business_email_active" ON "users" USING btree ("business_id","email") WHERE "users"."is_deleted" = false AND "users"."email" IS NOT NULL;--> statement-breakpoint
CREATE UNIQUE INDEX "uq_users_business_phone_active" ON "users" USING btree ("business_id","phone") WHERE "users"."is_deleted" = false AND "users"."phone" IS NOT NULL;--> statement-breakpoint
CREATE UNIQUE INDEX "uq_parties_business_mobile_active" ON "parties" USING btree ("business_id","mobile") WHERE "parties"."is_deleted" = false AND "parties"."mobile" IS NOT NULL;--> statement-breakpoint
CREATE UNIQUE INDEX "uq_party_links_business_parties" ON "party_links" USING btree ("business_id","party_id","linked_party_id");--> statement-breakpoint
CREATE UNIQUE INDEX "uq_party_loyalty_balances_party" ON "party_loyalty_balances" USING btree ("business_id","party_id");--> statement-breakpoint
CREATE UNIQUE INDEX "uq_party_tag_assignments_party_tag" ON "party_tag_assignments" USING btree ("party_id","party_tag_id");--> statement-breakpoint
CREATE UNIQUE INDEX "uq_item_tier_prices_item_tier" ON "item_tier_prices" USING btree ("item_id","pricing_tier");--> statement-breakpoint
CREATE UNIQUE INDEX "uq_item_units_item_unit" ON "item_units" USING btree ("item_id","unit_name");--> statement-breakpoint
CREATE UNIQUE INDEX "uq_items_business_barcode_active" ON "items" USING btree ("business_id","barcode") WHERE "items"."is_deleted" = false AND "items"."barcode" IS NOT NULL;--> statement-breakpoint
CREATE UNIQUE INDEX "uq_stock_levels_business_item_godown" ON "stock_levels" USING btree ("business_id","item_id","godown_id");--> statement-breakpoint
CREATE UNIQUE INDEX "uq_sales_documents_business_series_number" ON "sales_documents" USING btree ("business_id","document_series","document_number") WHERE "sales_documents"."document_number" IS NOT NULL;--> statement-breakpoint
CREATE UNIQUE INDEX "uq_purchase_documents_business_series_number" ON "purchase_documents" USING btree ("business_id","document_series","document_number") WHERE "purchase_documents"."document_number" IS NOT NULL;--> statement-breakpoint
CREATE UNIQUE INDEX "uq_online_orders_business_external" ON "online_orders" USING btree ("business_id","external_order_id");