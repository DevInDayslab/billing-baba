import { sql } from 'drizzle-orm';
import {
  index,
  integer,
  jsonb,
  pgEnum,
  pgTable,
  text,
  uniqueIndex,
  uuid,
} from 'drizzle-orm/pg-core';
import { payments } from '../accounting/tables';
import { businesses } from '../business/tables';
import { timestamptz, uuidPrimaryKey } from '../columns';
import {
  gatewayPaymentIntentStatusEnum,
  gatewayPaymentIntentTypeEnum,
} from '../enums';

export const GATEWAY_INTENT_PAYLOAD_VERSION = 1;

export type GatewayIntentPayloadV1 = {
  party_id: string;
  direction: 'received' | 'paid';
  amount: string;
  discount_amount?: string;
  notes?: string | null;
  short_payment_handling?: 'official_balance' | 'unrecovered' | null;
  shortfall_amount?: string | null;
  allocations?: Array<{
    sales_document_id?: string;
    purchase_document_id?: string;
    allocated_amount: string;
  }>;
  reference_number?: string | null;
  invoice_number?: string | null;
};

export type GatewayIntentPayload = GatewayIntentPayloadV1;

export const gatewayReconciliationJobStatusEnum = pgEnum(
  'gateway_reconciliation_job_status',
  ['pending', 'processing', 'completed', 'failed'],
);

export const gatewayPaymentIntents = pgTable(
  'gateway_payment_intents',
  {
    id: uuidPrimaryKey(),
    businessId: uuid('business_id')
      .notNull()
      .references(() => businesses.id),
    intentType: gatewayPaymentIntentTypeEnum('intent_type').notNull(),
    intentPayloadVersion: integer('intent_payload_version')
      .notNull()
      .default(GATEWAY_INTENT_PAYLOAD_VERSION),
    intentPayload: jsonb('intent_payload')
      .$type<GatewayIntentPayload>()
      .notNull(),
    businessName: text('business_name').notNull(),
    customerName: text('customer_name').notNull(),
    customerPhone: text('customer_phone'),
    customerEmail: text('customer_email'),
    amountPaise: integer('amount_paise').notNull(),
    currency: text('currency').notNull().default('INR'),
    razorpayOrderId: text('razorpay_order_id').notNull(),
    razorpayPaymentId: text('razorpay_payment_id'),
    status: gatewayPaymentIntentStatusEnum('status')
      .notNull()
      .default('created'),
    idempotencyKey: text('idempotency_key'),
    accountingPaymentId: uuid('accounting_payment_id').references(
      () => payments.id,
    ),
    failureReason: text('failure_reason'),
    paidAt: timestamptz('paid_at'),
    verifiedAt: timestamptz('verified_at'),
    createdAt: timestamptz('created_at').notNull().defaultNow(),
    updatedAt: timestamptz('updated_at').notNull().defaultNow(),
  },
  (table) => [
    uniqueIndex('uq_gateway_payment_intents_razorpay_order_id').on(
      table.razorpayOrderId,
    ),
    uniqueIndex('uq_gateway_payment_intents_razorpay_payment_id')
      .on(table.razorpayPaymentId)
      .where(sql`${table.razorpayPaymentId} IS NOT NULL`),
    uniqueIndex('uq_gateway_payment_intents_idempotency_key')
      .on(table.idempotencyKey)
      .where(sql`${table.idempotencyKey} IS NOT NULL`),
    index('idx_gateway_payment_intents_business_status').on(
      table.businessId,
      table.status,
    ),
  ],
);

export const gatewayReconciliationJobs = pgTable(
  'gateway_reconciliation_jobs',
  {
    id: uuidPrimaryKey(),
    intentId: uuid('intent_id')
      .notNull()
      .references(() => gatewayPaymentIntents.id),
    event: text('event').notNull(),
    razorpayOrderId: text('razorpay_order_id').notNull(),
    razorpayPaymentId: text('razorpay_payment_id'),
    payload: jsonb('payload').$type<Record<string, unknown>>(),
    status: gatewayReconciliationJobStatusEnum('status')
      .notNull()
      .default('pending'),
    attempts: integer('attempts').notNull().default(0),
    lastError: text('last_error'),
    createdAt: timestamptz('created_at').notNull().defaultNow(),
    processedAt: timestamptz('processed_at'),
  },
  (table) => [
    index('idx_gateway_reconciliation_jobs_status').on(
      table.status,
      table.createdAt,
    ),
  ],
);
