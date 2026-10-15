import { relations } from 'drizzle-orm';
import { bankAccounts } from '../bank-accounts/tables';
import {
  incomeCategories,
  incomeItems,
  otherIncomes,
} from './tables';

export const incomeCategoriesRelations = relations(
  incomeCategories,
  ({ many }) => ({
    otherIncomes: many(otherIncomes),
  }),
);

export const incomeItemsRelations = relations(incomeItems, ({ many }) => ({
  otherIncomes: many(otherIncomes),
}));

export const otherIncomesRelations = relations(otherIncomes, ({ one }) => ({
  category: one(incomeCategories, {
    fields: [otherIncomes.categoryId],
    references: [incomeCategories.id],
  }),
  incomeItem: one(incomeItems, {
    fields: [otherIncomes.incomeItemId],
    references: [incomeItems.id],
  }),
  bankAccount: one(bankAccounts, {
    fields: [otherIncomes.bankAccountId],
    references: [bankAccounts.id],
  }),
}));
