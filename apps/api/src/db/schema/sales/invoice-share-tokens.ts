import { index, pgTable, text, uniqueIndex, uuid } from 'drizzle-orm/pg-core';
import { businesses } from '../business/tables';
import { timestamptz, uuidPrimaryKey } from '../columns';
import { accounts } from '../identity/tables';
import { salesDocuments } from '../sales/tables';

/**
 * Cryptographically random public tokens for invoice share pages.
 * One token maps to exactly one sales document; tokens are not enumerable.
 */
export const invoiceShareTokens = pgTable(
  'invoice_share_tokens',
  {
    id: uuidPrimaryKey(),
    token: text('token').notNull(),
    invoiceId: uuid('invoice_id')
      .notNull()
      .references(() => salesDocuments.id),
    businessId: uuid('business_id')
      .notNull()
      .references(() => businesses.id),
    expiresAt: timestamptz('expires_at'),
    createdAt: timestamptz('created_at').notNull().defaultNow(),
    createdBy: uuid('created_by').references(() => accounts.id),
  },
  (table) => [
    uniqueIndex('uq_invoice_share_tokens_token').on(table.token),
    index('idx_invoice_share_tokens_invoice').on(table.invoiceId),
    index('idx_invoice_share_tokens_business').on(table.businessId),
  ],
);
