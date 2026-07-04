import { relations } from 'drizzle-orm';
import { parties } from '../crm/tables';
import { items } from '../inventory/tables';
import {
  expenseCategories,
  expenses,
  purchaseDocumentLines,
  purchaseDocuments,
  purchaseFaBatches,
  purchaseFixedAssets,
} from './tables';

export const expenseCategoriesRelations = relations(
  expenseCategories,
  ({ many }) => ({
    expenses: many(expenses),
  }),
);

export const purchaseDocumentsRelations = relations(
  purchaseDocuments,
  ({ one, many }) => ({
    party: one(parties, {
      fields: [purchaseDocuments.partyId],
      references: [parties.id],
    }),
    convertedFrom: one(purchaseDocuments, {
      fields: [purchaseDocuments.convertedFromId],
      references: [purchaseDocuments.id],
      relationName: 'conversion_chain',
    }),
    lines: many(purchaseDocumentLines),
    fixedAssets: many(purchaseFixedAssets),
  }),
);

export const purchaseDocumentLinesRelations = relations(
  purchaseDocumentLines,
  ({ one }) => ({
    document: one(purchaseDocuments, {
      fields: [purchaseDocumentLines.purchaseDocumentId],
      references: [purchaseDocuments.id],
    }),
    item: one(items, {
      fields: [purchaseDocumentLines.itemId],
      references: [items.id],
    }),
  }),
);

export const expensesRelations = relations(expenses, ({ one }) => ({
  category: one(expenseCategories, {
    fields: [expenses.categoryId],
    references: [expenseCategories.id],
  }),
  party: one(parties, {
    fields: [expenses.partyId],
    references: [parties.id],
  }),
}));

export const purchaseFaBatchesRelations = relations(
  purchaseFaBatches,
  ({ one, many }) => ({
    party: one(parties, {
      fields: [purchaseFaBatches.partyId],
      references: [parties.id],
    }),
    assets: many(purchaseFixedAssets),
  }),
);

export const purchaseFixedAssetsRelations = relations(
  purchaseFixedAssets,
  ({ one }) => ({
    batch: one(purchaseFaBatches, {
      fields: [purchaseFixedAssets.batchId],
      references: [purchaseFaBatches.id],
    }),
    purchaseDocument: one(purchaseDocuments, {
      fields: [purchaseFixedAssets.purchaseDocumentId],
      references: [purchaseDocuments.id],
    }),
  }),
);
