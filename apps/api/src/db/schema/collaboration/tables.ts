import { sql } from 'drizzle-orm';
import {
  check,
  index,
  pgTable,
  text,
  uniqueIndex,
  uuid,
} from 'drizzle-orm/pg-core';
import { businesses } from '../business/tables';
import { timestamptz, uuidPrimaryKey } from '../columns';
import {
  collaborationRoleEnum,
  companyMemberStatusEnum,
  invitationStatusEnum,
} from '../enums';
import { accounts } from '../identity/tables';

export const companyMembers = pgTable(
  'company_members',
  {
    id: uuidPrimaryKey(),
    companyId: uuid('company_id')
      .notNull()
      .references(() => businesses.id),
    accountId: uuid('account_id')
      .notNull()
      .references(() => accounts.id),
    role: collaborationRoleEnum('role').notNull(),
    status: companyMemberStatusEnum('status').notNull().default('active'),
    joinedAt: timestamptz('joined_at'),
    leftAt: timestamptz('left_at'),
    createdAt: timestamptz('created_at').notNull().defaultNow(),
    updatedAt: timestamptz('updated_at').notNull().defaultNow(),
  },
  (table) => [
    uniqueIndex('uq_company_members_active')
      .on(table.companyId, table.accountId)
      .where(sql`${table.status} = 'active'`),
    index('idx_company_members_account').on(table.accountId),
    index('idx_company_members_company_status').on(
      table.companyId,
      table.status,
    ),
  ],
);

export const invitations = pgTable(
  'invitations',
  {
    id: uuidPrimaryKey(),
    companyId: uuid('company_id')
      .notNull()
      .references(() => businesses.id),
    inviteeName: text('invitee_name').notNull(),
    phone: text('phone'),
    email: text('email'),
    role: collaborationRoleEnum('role').notNull(),
    status: invitationStatusEnum('status').notNull().default('pending'),
    token: text('token').notNull(),
    placeholderMemberId: uuid('placeholder_member_id')
      .notNull()
      .defaultRandom(),
    createdBy: uuid('created_by')
      .notNull()
      .references(() => accounts.id),
    openedAt: timestamptz('opened_at'),
    acceptedAt: timestamptz('accepted_at'),
    rejectedAt: timestamptz('rejected_at'),
    expiresAt: timestamptz('expires_at').notNull(),
    supersededBy: uuid('superseded_by'),
    createdAt: timestamptz('created_at').notNull().defaultNow(),
    updatedAt: timestamptz('updated_at').notNull().defaultNow(),
  },
  (table) => [
    uniqueIndex('uq_invitations_token').on(table.token),
    uniqueIndex('uq_invitations_company_phone_active')
      .on(table.companyId, table.phone)
      .where(
        sql`${table.phone} IS NOT NULL AND ${table.status} IN ('pending', 'opened')`,
      ),
    index('idx_invitations_company').on(table.companyId),
    index('idx_invitations_phone').on(table.phone),
    index('idx_invitations_email').on(table.email),
    check(
      'invitations_phone_or_email',
      sql`${table.phone} IS NOT NULL OR ${table.email} IS NOT NULL`,
    ),
  ],
);
