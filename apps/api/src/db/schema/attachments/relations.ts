import { relations } from 'drizzle-orm';
import { businesses } from '../business/tables';
import { documentAttachments } from './tables';

export const documentAttachmentsRelations = relations(
  documentAttachments,
  ({ one }) => ({
    business: one(businesses, {
      fields: [documentAttachments.businessId],
      references: [businesses.id],
    }),
  }),
);
