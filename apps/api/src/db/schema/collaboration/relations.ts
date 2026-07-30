import { relations } from 'drizzle-orm';
import { businesses } from '../business/tables';
import { accounts } from '../identity/tables';
import { companyMembers, invitations } from './tables';

export const companyMembersRelations = relations(companyMembers, ({ one }) => ({
  company: one(businesses, {
    fields: [companyMembers.companyId],
    references: [businesses.id],
  }),
  account: one(accounts, {
    fields: [companyMembers.accountId],
    references: [accounts.id],
  }),
}));

export const invitationsRelations = relations(invitations, ({ one }) => ({
  company: one(businesses, {
    fields: [invitations.companyId],
    references: [businesses.id],
  }),
  creator: one(accounts, {
    fields: [invitations.createdBy],
    references: [accounts.id],
  }),
  supersededByInvitation: one(invitations, {
    fields: [invitations.supersededBy],
    references: [invitations.id],
    relationName: 'superseded_invitation',
  }),
}));
