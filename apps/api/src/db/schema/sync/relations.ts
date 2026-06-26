import { relations } from 'drizzle-orm';
import { onlineOrders } from './tables';
import { parties } from '../crm/tables';
import { salesDocuments } from '../sales/tables';

export const onlineOrdersRelations = relations(onlineOrders, ({ one }) => ({
  party: one(parties, {
    fields: [onlineOrders.partyId],
    references: [parties.id],
  }),
  salesDocument: one(salesDocuments, {
    fields: [onlineOrders.salesDocumentId],
    references: [salesDocuments.id],
  }),
}));
