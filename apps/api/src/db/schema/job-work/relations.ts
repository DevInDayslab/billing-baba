import { relations } from 'drizzle-orm';
import { parties } from '../crm/tables';
import { items } from '../inventory/tables';
import {
  jobWorkAdditionalCosts,
  jobWorkOrders,
  jobWorkRawMaterialLines,
} from './tables';

export const jobWorkOrdersRelations = relations(
  jobWorkOrders,
  ({ one, many }) => ({
    party: one(parties, {
      fields: [jobWorkOrders.partyId],
      references: [parties.id],
    }),
    rawMaterialLines: many(jobWorkRawMaterialLines),
    additionalCosts: many(jobWorkAdditionalCosts),
  }),
);

export const jobWorkRawMaterialLinesRelations = relations(
  jobWorkRawMaterialLines,
  ({ one }) => ({
    jobWorkOrder: one(jobWorkOrders, {
      fields: [jobWorkRawMaterialLines.jobWorkOrderId],
      references: [jobWorkOrders.id],
    }),
    item: one(items, {
      fields: [jobWorkRawMaterialLines.itemId],
      references: [items.id],
    }),
  }),
);

export const jobWorkAdditionalCostsRelations = relations(
  jobWorkAdditionalCosts,
  ({ one }) => ({
    jobWorkOrder: one(jobWorkOrders, {
      fields: [jobWorkAdditionalCosts.jobWorkOrderId],
      references: [jobWorkOrders.id],
    }),
  }),
);
