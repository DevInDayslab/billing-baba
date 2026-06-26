import { relations } from 'drizzle-orm';
import { parties } from '../crm/tables';
import { users } from '../identity/tables';
import { items } from '../inventory/tables';
import { posSessions, salesDocumentLines, salesDocuments } from './tables';

export const posSessionsRelations = relations(posSessions, ({ one, many }) => ({
  user: one(users, {
    fields: [posSessions.userId],
    references: [users.id],
  }),
  documents: many(salesDocuments),
}));

export const salesDocumentsRelations = relations(
  salesDocuments,
  ({ one, many }) => ({
    party: one(parties, {
      fields: [salesDocuments.partyId],
      references: [parties.id],
    }),
    convertedFrom: one(salesDocuments, {
      fields: [salesDocuments.convertedFromId],
      references: [salesDocuments.id],
      relationName: 'conversion_chain',
    }),
    posSession: one(posSessions, {
      fields: [salesDocuments.posSessionId],
      references: [posSessions.id],
    }),
    lines: many(salesDocumentLines),
  }),
);

export const salesDocumentLinesRelations = relations(
  salesDocumentLines,
  ({ one }) => ({
    document: one(salesDocuments, {
      fields: [salesDocumentLines.salesDocumentId],
      references: [salesDocuments.id],
    }),
    item: one(items, {
      fields: [salesDocumentLines.itemId],
      references: [items.id],
    }),
  }),
);
