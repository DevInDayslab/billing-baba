import { sql } from 'drizzle-orm';
import {
  boolean,
  index,
  integer,
  jsonb,
  pgTable,
  text,
  uniqueIndex,
  uuid,
} from 'drizzle-orm/pg-core';
import { businesses } from '../business/tables';
import { money, timestamptz, uuidPrimaryKey } from '../columns';
import {
  paymentStatusEnum,
  subscriptionPlanEnum,
  subscriptionStatusEnum,
} from '../enums';

export const subscriptionPlans = pgTable(
  'subscription_plans',
  {
    id: uuidPrimaryKey(),
    plan: subscriptionPlanEnum('plan').notNull(),
    name: text('name').notNull(),
    price: money('price').notNull().default('0'),
    durationDays: integer('duration_days').notNull().default(0),
    isActive: boolean('is_active').notNull().default(true),
    createdAt: timestamptz('created_at').notNull().defaultNow(),
    updatedAt: timestamptz('updated_at').notNull().defaultNow(),
  },
  (table) => [uniqueIndex('uq_subscription_plans_plan').on(table.plan)],
);

export const subscriptions = pgTable(
  'subscriptions',
  {
    id: uuidPrimaryKey(),
    businessId: uuid('business_id')
      .notNull()
      .references(() => businesses.id),
    plan: subscriptionPlanEnum('plan').notNull(),
    status: subscriptionStatusEnum('status').notNull().default('pending'),
    startsAt: timestamptz('starts_at'),
    expiresAt: timestamptz('expires_at'),
    createdAt: timestamptz('created_at').notNull().defaultNow(),
    updatedAt: timestamptz('updated_at').notNull().defaultNow(),
  },
  (table) => [
    index('idx_subscriptions_business_status').on(
      table.businessId,
      table.status,
    ),
    index('idx_subscriptions_expires_at').on(table.expiresAt),
  ],
);

export const subscriptionPayments = pgTable(
  'subscription_payments',
  {
    id: uuidPrimaryKey(),
    businessId: uuid('business_id')
      .notNull()
      .references(() => businesses.id),
    subscriptionId: uuid('subscription_id').references(() => subscriptions.id),
    plan: subscriptionPlanEnum('plan').notNull(),
    amount: money('amount').notNull(),
    currency: text('currency').notNull().default('INR'),
    razorpayOrderId: text('razorpay_order_id').notNull(),
    razorpayPaymentId: text('razorpay_payment_id'),
    paymentStatus: paymentStatusEnum('payment_status')
      .notNull()
      .default('created'),
    paidAt: timestamptz('paid_at'),
    createdAt: timestamptz('created_at').notNull().defaultNow(),
  },
  (table) => [
    uniqueIndex('uq_subscription_payments_razorpay_order_id').on(
      table.razorpayOrderId,
    ),
    uniqueIndex('uq_subscription_payments_razorpay_payment_id')
      .on(table.razorpayPaymentId)
      .where(sql`${table.razorpayPaymentId} IS NOT NULL`),
    index('idx_subscription_payments_business_id').on(table.businessId),
  ],
);

export const subscriptionHistory = pgTable(
  'subscription_history',
  {
    id: uuidPrimaryKey(),
    businessId: uuid('business_id')
      .notNull()
      .references(() => businesses.id),
    oldPlan: subscriptionPlanEnum('old_plan').notNull(),
    newPlan: subscriptionPlanEnum('new_plan').notNull(),
    event: text('event').notNull(),
    metadata: jsonb('metadata').$type<Record<string, unknown>>(),
    createdAt: timestamptz('created_at').notNull().defaultNow(),
  },
  (table) => [
    index('idx_subscription_history_business_id').on(
      table.businessId,
      table.createdAt,
    ),
  ],
);
