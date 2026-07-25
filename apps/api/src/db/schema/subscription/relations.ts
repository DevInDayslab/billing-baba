import { relations } from 'drizzle-orm';
import { businesses } from '../business/tables';
import {
  subscriptionHistory,
  subscriptionPayments,
  subscriptions,
} from './tables';

export const subscriptionsRelations = relations(
  subscriptions,
  ({ one, many }) => ({
    business: one(businesses, {
      fields: [subscriptions.businessId],
      references: [businesses.id],
    }),
    payments: many(subscriptionPayments),
  }),
);

export const subscriptionPaymentsRelations = relations(
  subscriptionPayments,
  ({ one }) => ({
    business: one(businesses, {
      fields: [subscriptionPayments.businessId],
      references: [businesses.id],
    }),
    subscription: one(subscriptions, {
      fields: [subscriptionPayments.subscriptionId],
      references: [subscriptions.id],
    }),
  }),
);

export const subscriptionHistoryRelations = relations(
  subscriptionHistory,
  ({ one }) => ({
    business: one(businesses, {
      fields: [subscriptionHistory.businessId],
      references: [businesses.id],
    }),
  }),
);
