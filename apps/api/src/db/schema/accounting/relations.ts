import { relations } from 'drizzle-orm';
import { parties } from '../crm/tables';
import { purchaseDocuments } from '../purchases/tables';
import { salesDocuments } from '../sales/tables';
import { ledgerEntries, paymentAllocations, payments } from './tables';

export const ledgerEntriesRelations = relations(ledgerEntries, ({ one }) => ({
  party: one(parties, {
    fields: [ledgerEntries.partyId],
    references: [parties.id],
  }),
}));

export const paymentsRelations = relations(payments, ({ one, many }) => ({
  party: one(parties, {
    fields: [payments.partyId],
    references: [parties.id],
  }),
  allocations: many(paymentAllocations),
}));

export const paymentAllocationsRelations = relations(
  paymentAllocations,
  ({ one }) => ({
    payment: one(payments, {
      fields: [paymentAllocations.paymentId],
      references: [payments.id],
    }),
    salesDocument: one(salesDocuments, {
      fields: [paymentAllocations.salesDocumentId],
      references: [salesDocuments.id],
    }),
    purchaseDocument: one(purchaseDocuments, {
      fields: [paymentAllocations.purchaseDocumentId],
      references: [purchaseDocuments.id],
    }),
  }),
);
