import { relations } from 'drizzle-orm';
import { businesses } from '../business/tables';
import { users } from '../identity/tables';
import { areas } from '../settings/tables';
import {
  parties,
  partyAttachments,
  partyLinks,
  partyLoyaltyBalances,
  loyaltyTransactions,
  partyTagAssignments,
  partyTags,
  partyVisits,
} from './tables';

export const partiesRelations = relations(parties, ({ one, many }) => ({
  business: one(businesses, {
    fields: [parties.businessId],
    references: [businesses.id],
  }),
  area: one(areas, {
    fields: [parties.areaId],
    references: [areas.id],
  }),
  visits: many(partyVisits),
  attachments: many(partyAttachments),
  links: many(partyLinks),
  tagAssignments: many(partyTagAssignments),
  loyaltyBalance: one(partyLoyaltyBalances),
  loyaltyTransactions: many(loyaltyTransactions),
}));

export const partyVisitsRelations = relations(partyVisits, ({ one }) => ({
  party: one(parties, {
    fields: [partyVisits.partyId],
    references: [parties.id],
  }),
  recordedByUser: one(users, {
    fields: [partyVisits.recordedBy],
    references: [users.id],
  }),
}));

export const partyAttachmentsRelations = relations(
  partyAttachments,
  ({ one }) => ({
    party: one(parties, {
      fields: [partyAttachments.partyId],
      references: [parties.id],
    }),
  }),
);

export const partyLinksRelations = relations(partyLinks, ({ one }) => ({
  party: one(parties, {
    fields: [partyLinks.partyId],
    references: [parties.id],
  }),
  linkedParty: one(parties, {
    fields: [partyLinks.linkedPartyId],
    references: [parties.id],
  }),
}));

export const partyTagsRelations = relations(partyTags, ({ many }) => ({
  assignments: many(partyTagAssignments),
}));

export const partyTagAssignmentsRelations = relations(
  partyTagAssignments,
  ({ one }) => ({
    party: one(parties, {
      fields: [partyTagAssignments.partyId],
      references: [parties.id],
    }),
    tag: one(partyTags, {
      fields: [partyTagAssignments.partyTagId],
      references: [partyTags.id],
    }),
  }),
);

export const partyLoyaltyBalancesRelations = relations(
  partyLoyaltyBalances,
  ({ one }) => ({
    party: one(parties, {
      fields: [partyLoyaltyBalances.partyId],
      references: [parties.id],
    }),
  }),
);

export const loyaltyTransactionsRelations = relations(
  loyaltyTransactions,
  ({ one }) => ({
    party: one(parties, {
      fields: [loyaltyTransactions.partyId],
      references: [parties.id],
    }),
  }),
);
