import { relations } from 'drizzle-orm';
import { businesses } from '../business/tables';
import {
  areas,
  businessSettings,
  documentNumberSequences,
  loyaltyRules,
  taxRates,
} from './tables';

export const areasRelations = relations(areas, ({ one }) => ({
  business: one(businesses, {
    fields: [areas.businessId],
    references: [businesses.id],
  }),
}));

export const businessSettingsRelations = relations(
  businessSettings,
  ({ one }) => ({
    business: one(businesses, {
      fields: [businessSettings.businessId],
      references: [businesses.id],
    }),
  }),
);

export const taxRatesRelations = relations(taxRates, ({ one }) => ({
  business: one(businesses, {
    fields: [taxRates.businessId],
    references: [businesses.id],
  }),
}));

export const documentNumberSequencesRelations = relations(
  documentNumberSequences,
  ({ one }) => ({
    business: one(businesses, {
      fields: [documentNumberSequences.businessId],
      references: [businesses.id],
    }),
  }),
);

export const loyaltyRulesRelations = relations(loyaltyRules, ({ one }) => ({
  business: one(businesses, {
    fields: [loyaltyRules.businessId],
    references: [businesses.id],
  }),
}));
