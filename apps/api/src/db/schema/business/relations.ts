import { relations } from 'drizzle-orm';
import { parties } from '../crm/tables';
import { users } from '../identity/tables';
import { branches, businesses } from './tables';

export const businessesRelations = relations(businesses, ({ many }) => ({
  branches: many(branches),
  users: many(users),
  parties: many(parties),
}));

export const branchesRelations = relations(branches, ({ one }) => ({
  business: one(businesses, {
    fields: [branches.businessId],
    references: [businesses.id],
  }),
}));
