import { relations } from 'drizzle-orm';
import { businesses, branches } from './tables';
import { users } from '../identity/tables';
import { parties } from '../crm/tables';

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
