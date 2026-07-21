import { randomBytes } from 'node:crypto';
import { and, asc, eq, inArray, or } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { businesses } from '../../db/schema/business/tables';
import {
  companyMembers,
  invitations,
} from '../../db/schema/collaboration/tables';
import { accounts, users } from '../../db/schema/identity/tables';
import type {
  BusinessOwnerInfo,
  CollaborationRole,
  CompanyMemberRow,
  InvitationRow,
} from './collaboration.types';

const INVITE_CODE_CHARS = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
const INVITE_CODE_LENGTH = 6;

export function generateInvitationToken(): string {
  const bytes = randomBytes(INVITE_CODE_LENGTH);
  let code = '';
  for (let i = 0; i < INVITE_CODE_LENGTH; i++) {
    code += INVITE_CODE_CHARS[bytes[i]! % INVITE_CODE_CHARS.length]!;
  }
  return code;
}

export class CollaborationRepository {
  constructor(private readonly db: Database) {}

  async isBusinessOwner(
    businessId: string,
    accountId: string,
  ): Promise<boolean> {
    const [row] = await this.db
      .select({ id: users.id })
      .from(users)
      .where(
        and(
          eq(users.businessId, businessId),
          eq(users.accountId, accountId),
          eq(users.role, 'owner'),
          eq(users.isActive, true),
          eq(users.isDeleted, false),
        ),
      )
      .limit(1);

    return Boolean(row);
  }

  async getBusinessOwnerInfo(
    companyId: string,
  ): Promise<BusinessOwnerInfo | null> {
    const [row] = await this.db
      .select({
        companyId: businesses.id,
        companyName: businesses.name,
        ownerName: users.name,
        ownerPhone: accounts.phone,
        logoUrl: businesses.logoUrl,
        logoMediaAssetId: businesses.logoMediaAssetId,
      })
      .from(businesses)
      .innerJoin(users, eq(users.businessId, businesses.id))
      .innerJoin(accounts, eq(accounts.id, users.accountId))
      .where(
        and(
          eq(businesses.id, companyId),
          eq(users.role, 'owner'),
          eq(users.isDeleted, false),
          eq(businesses.isDeleted, false),
        ),
      )
      .limit(1);

    if (!row) return null;

    return {
      companyId: row.companyId,
      companyName: row.companyName,
      ownerName: row.ownerName,
      ownerPhone: row.ownerPhone,
      logoUrl: row.logoUrl,
      logoMediaAssetId: row.logoMediaAssetId,
    };
  }

  async findActiveMemberByContact(
    companyId: string,
    phone: string | null,
    email: string | null,
  ): Promise<CompanyMemberRow | null> {
    if (!phone && !email) return null;

    const contactConditions = [];
    if (phone) {
      contactConditions.push(eq(accounts.phone, phone));
    }
    if (email) {
      contactConditions.push(eq(accounts.email, email));
    }

    const [row] = await this.db
      .select({
        id: companyMembers.id,
        companyId: companyMembers.companyId,
        accountId: companyMembers.accountId,
        role: companyMembers.role,
        status: companyMembers.status,
        joinedAt: companyMembers.joinedAt,
        leftAt: companyMembers.leftAt,
        createdAt: companyMembers.createdAt,
        updatedAt: companyMembers.updatedAt,
      })
      .from(companyMembers)
      .innerJoin(accounts, eq(accounts.id, companyMembers.accountId))
      .where(
        and(
          eq(companyMembers.companyId, companyId),
          eq(companyMembers.status, 'active'),
          or(...contactConditions),
        ),
      )
      .limit(1);

    return row ?? null;
  }

  async findActiveInvitationByContact(
    companyId: string,
    phone: string | null,
    email: string | null,
  ): Promise<InvitationRow | null> {
    const conditions = [
      eq(invitations.companyId, companyId),
      inArray(invitations.status, ['pending', 'opened']),
    ];

    if (phone) {
      conditions.push(eq(invitations.phone, phone));
    } else if (email) {
      conditions.push(eq(invitations.email, email));
    } else {
      return null;
    }

    const [row] = await this.db
      .select()
      .from(invitations)
      .where(and(...conditions))
      .limit(1);

    return (row as InvitationRow | undefined) ?? null;
  }

  async createInvitation(input: {
    companyId: string;
    inviteeName: string;
    phone: string | null;
    email: string | null;
    role: CollaborationRole;
    createdBy: string;
    expiresAt: Date;
    token: string;
  }): Promise<InvitationRow> {
    const [row] = await this.db
      .insert(invitations)
      .values({
        companyId: input.companyId,
        inviteeName: input.inviteeName,
        phone: input.phone,
        email: input.email,
        role: input.role,
        createdBy: input.createdBy,
        expiresAt: input.expiresAt,
        token: input.token,
        status: 'pending',
      })
      .returning();

    return row as InvitationRow;
  }

  async findInvitationByToken(token: string): Promise<InvitationRow | null> {
    const [row] = await this.db
      .select()
      .from(invitations)
      .where(eq(invitations.token, token))
      .limit(1);

    return (row as InvitationRow | undefined) ?? null;
  }

  async findInvitationById(id: string): Promise<InvitationRow | null> {
    const [row] = await this.db
      .select()
      .from(invitations)
      .where(eq(invitations.id, id))
      .limit(1);

    return (row as InvitationRow | undefined) ?? null;
  }

  async listInvitationsForCompany(companyId: string): Promise<InvitationRow[]> {
    const rows = await this.db
      .select()
      .from(invitations)
      .where(eq(invitations.companyId, companyId))
      .orderBy(asc(invitations.createdAt));

    return rows as InvitationRow[];
  }

  async markInvitationOpened(id: string): Promise<InvitationRow | null> {
    const now = new Date();
    const [row] = await this.db
      .update(invitations)
      .set({
        status: 'opened',
        openedAt: now,
        updatedAt: now,
      })
      .where(and(eq(invitations.id, id), eq(invitations.status, 'pending')))
      .returning();

    return (row as InvitationRow | undefined) ?? null;
  }

  async markInvitationExpired(id: string): Promise<InvitationRow | null> {
    const now = new Date();
    const [row] = await this.db
      .update(invitations)
      .set({
        status: 'expired',
        updatedAt: now,
      })
      .where(
        and(
          eq(invitations.id, id),
          inArray(invitations.status, ['pending', 'opened']),
        ),
      )
      .returning();

    return (row as InvitationRow | undefined) ?? null;
  }

  async markInvitationAccepted(id: string): Promise<InvitationRow | null> {
    const now = new Date();
    const [row] = await this.db
      .update(invitations)
      .set({
        status: 'accepted',
        acceptedAt: now,
        updatedAt: now,
      })
      .where(
        and(
          eq(invitations.id, id),
          inArray(invitations.status, ['pending', 'opened']),
        ),
      )
      .returning();

    return (row as InvitationRow | undefined) ?? null;
  }

  async markInvitationRejected(id: string): Promise<InvitationRow | null> {
    const now = new Date();
    const [row] = await this.db
      .update(invitations)
      .set({
        status: 'rejected',
        rejectedAt: now,
        updatedAt: now,
      })
      .where(
        and(
          eq(invitations.id, id),
          inArray(invitations.status, ['pending', 'opened']),
        ),
      )
      .returning();

    return (row as InvitationRow | undefined) ?? null;
  }

  async cancelInvitation(
    id: string,
    supersededBy: string | null,
  ): Promise<InvitationRow | null> {
    const now = new Date();
    const [row] = await this.db
      .update(invitations)
      .set({
        status: 'cancelled',
        supersededBy,
        updatedAt: now,
      })
      .where(
        and(
          eq(invitations.id, id),
          inArray(invitations.status, ['pending', 'opened']),
        ),
      )
      .returning();

    return (row as InvitationRow | undefined) ?? null;
  }

  async findOrCreateAccount(input: {
    phone: string | null;
    email: string | null;
    name: string;
  }): Promise<{ id: string; phone: string; email: string | null }> {
    if (input.phone) {
      const [existing] = await this.db
        .select()
        .from(accounts)
        .where(eq(accounts.phone, input.phone))
        .limit(1);

      if (existing) {
        return {
          id: existing.id,
          phone: existing.phone,
          email: existing.email,
        };
      }

      const [created] = await this.db
        .insert(accounts)
        .values({
          phone: input.phone,
          name: input.name,
          email: input.email,
        })
        .returning();

      if (!created) {
        throw new Error('Failed to create account');
      }

      return {
        id: created.id,
        phone: created.phone,
        email: created.email,
      };
    }

    if (!input.email) {
      throw new Error('Phone or email is required to create an account');
    }

    const [existingByEmail] = await this.db
      .select()
      .from(accounts)
      .where(eq(accounts.email, input.email))
      .limit(1);

    if (existingByEmail) {
      return {
        id: existingByEmail.id,
        phone: existingByEmail.phone,
        email: existingByEmail.email,
      };
    }

    const placeholderPhone = `+invite${randomBytes(8).toString('hex')}`;
    const [created] = await this.db
      .insert(accounts)
      .values({
        phone: placeholderPhone,
        name: input.name,
        email: input.email,
      })
      .returning();

    if (!created) {
      throw new Error('Failed to create account');
    }

    return {
      id: created.id,
      phone: created.phone,
      email: created.email,
    };
  }

  async createCompanyMember(input: {
    companyId: string;
    accountId: string;
    role: CollaborationRole;
    joinedAt: Date;
  }): Promise<CompanyMemberRow> {
    const [row] = await this.db
      .insert(companyMembers)
      .values({
        companyId: input.companyId,
        accountId: input.accountId,
        role: input.role,
        status: 'active',
        joinedAt: input.joinedAt,
      })
      .returning();

    return row as CompanyMemberRow;
  }

  async findCompanyMemberById(id: string): Promise<CompanyMemberRow | null> {
    const [row] = await this.db
      .select()
      .from(companyMembers)
      .where(eq(companyMembers.id, id))
      .limit(1);

    return (row as CompanyMemberRow | undefined) ?? null;
  }

  async markMemberLeft(id: string): Promise<CompanyMemberRow | null> {
    const now = new Date();
    const [row] = await this.db
      .update(companyMembers)
      .set({
        status: 'left',
        leftAt: now,
        updatedAt: now,
      })
      .where(
        and(eq(companyMembers.id, id), eq(companyMembers.status, 'active')),
      )
      .returning();

    return (row as CompanyMemberRow | undefined) ?? null;
  }

  async markInvitationLeftByMember(
    companyId: string,
    accountId: string,
  ): Promise<void> {
    const account = await this.getAccountById(accountId);
    if (!account) return;

    const now = new Date();
    const conditions = [
      eq(invitations.companyId, companyId),
      eq(invitations.status, 'accepted'),
    ];

    if (account.phone) {
      await this.db
        .update(invitations)
        .set({ status: 'left', updatedAt: now })
        .where(and(...conditions, eq(invitations.phone, account.phone)));
    }

    if (account.email) {
      await this.db
        .update(invitations)
        .set({ status: 'left', updatedAt: now })
        .where(and(...conditions, eq(invitations.email, account.email)));
    }
  }

  async listActiveSharedCompanies(
    accountId: string,
  ): Promise<Array<CompanyMemberRow & { companyName: string }>> {
    const rows = await this.db
      .select({
        id: companyMembers.id,
        companyId: companyMembers.companyId,
        accountId: companyMembers.accountId,
        role: companyMembers.role,
        status: companyMembers.status,
        joinedAt: companyMembers.joinedAt,
        leftAt: companyMembers.leftAt,
        createdAt: companyMembers.createdAt,
        updatedAt: companyMembers.updatedAt,
        companyName: businesses.name,
      })
      .from(companyMembers)
      .innerJoin(businesses, eq(businesses.id, companyMembers.companyId))
      .where(
        and(
          eq(companyMembers.accountId, accountId),
          eq(companyMembers.status, 'active'),
          eq(businesses.isDeleted, false),
        ),
      );

    return rows;
  }

  async listPendingInvitationsForAccount(
    phone: string,
    email: string | null,
  ): Promise<InvitationRow[]> {
    const contactConditions = [eq(invitations.phone, phone)];
    if (email) {
      contactConditions.push(eq(invitations.email, email));
    }

    const rows = await this.db
      .select()
      .from(invitations)
      .where(
        and(
          or(...contactConditions),
          inArray(invitations.status, ['pending', 'opened', 'expired']),
        ),
      );

    return rows as InvitationRow[];
  }

  async getAccountById(
    accountId: string,
  ): Promise<{ id: string; phone: string; email: string | null } | null> {
    const [row] = await this.db
      .select({
        id: accounts.id,
        phone: accounts.phone,
        email: accounts.email,
      })
      .from(accounts)
      .where(eq(accounts.id, accountId))
      .limit(1);

    return row ?? null;
  }

  async getBusinessOwnerAccountId(companyId: string): Promise<string | null> {
    const [row] = await this.db
      .select({ accountId: users.accountId })
      .from(users)
      .where(
        and(
          eq(users.businessId, companyId),
          eq(users.role, 'owner'),
          eq(users.isDeleted, false),
          eq(users.isActive, true),
        ),
      )
      .limit(1);

    return row?.accountId ?? null;
  }

  async findInvitationByPlaceholderMemberId(
    companyId: string,
    placeholderMemberId: string,
  ): Promise<InvitationRow | null> {
    const [row] = await this.db
      .select()
      .from(invitations)
      .where(
        and(
          eq(invitations.companyId, companyId),
          eq(invitations.placeholderMemberId, placeholderMemberId),
        ),
      )
      .orderBy(asc(invitations.createdAt))
      .limit(1);

    return (row as InvitationRow | undefined) ?? null;
  }

  async findLatestInvitationByPlaceholderMemberId(
    companyId: string,
    placeholderMemberId: string,
  ): Promise<InvitationRow | null> {
    const rows = await this.db
      .select()
      .from(invitations)
      .where(
        and(
          eq(invitations.companyId, companyId),
          eq(invitations.placeholderMemberId, placeholderMemberId),
        ),
      )
      .orderBy(asc(invitations.createdAt));

    if (rows.length === 0) return null;
    return rows[rows.length - 1] as InvitationRow;
  }

  async updateInvitationRole(
    invitationId: string,
    role: CollaborationRole,
  ): Promise<InvitationRow | null> {
    const now = new Date();
    const [row] = await this.db
      .update(invitations)
      .set({ role, updatedAt: now })
      .where(eq(invitations.id, invitationId))
      .returning();

    return (row as InvitationRow | undefined) ?? null;
  }

  async updateCompanyMemberRole(
    memberId: string,
    role: CollaborationRole,
  ): Promise<CompanyMemberRow | null> {
    const now = new Date();
    const [row] = await this.db
      .update(companyMembers)
      .set({ role, updatedAt: now })
      .where(
        and(eq(companyMembers.id, memberId), eq(companyMembers.status, 'active')),
      )
      .returning();

    return (row as CompanyMemberRow | undefined) ?? null;
  }

  async findActiveCompanyMemberByContact(
    companyId: string,
    phone: string | null,
    email: string | null,
  ): Promise<CompanyMemberRow | null> {
    return this.findActiveMemberByContact(companyId, phone, email);
  }

  async markMemberRemoved(id: string): Promise<CompanyMemberRow | null> {
    const now = new Date();
    const [row] = await this.db
      .update(companyMembers)
      .set({
        status: 'removed',
        leftAt: now,
        updatedAt: now,
      })
      .where(
        and(eq(companyMembers.id, id), eq(companyMembers.status, 'active')),
      )
      .returning();

    return (row as CompanyMemberRow | undefined) ?? null;
  }

  async markInvitationRemovedByContact(
    companyId: string,
    phone: string | null,
    email: string | null,
  ): Promise<void> {
    const now = new Date();
    const contactConditions = [];
    if (phone) contactConditions.push(eq(invitations.phone, phone));
    if (email) contactConditions.push(eq(invitations.email, email));
    if (contactConditions.length === 0) return;

    await this.db
      .update(invitations)
      .set({ status: 'left', updatedAt: now })
      .where(
        and(
          eq(invitations.companyId, companyId),
          eq(invitations.status, 'accepted'),
          or(...contactConditions),
        ),
      );
  }
}
