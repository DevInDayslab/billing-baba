import { and, count, desc, eq, gte, ilike, lte, or, sql } from 'drizzle-orm';
import type { Database } from '../../../db/client';
import { leadActivities, leads } from '../../../db/schema/crm/tables';
import { users } from '../../../db/schema/identity/tables';
import type {
  LeadActivityInsertValues,
  LeadActivityRecord,
  LeadInsertValues,
  LeadRecord,
  LeadUpdateValues,
  LeadWithActivitiesRecord,
  ListLeadsParams,
} from '../lead.types';

type LeadRow = typeof leads.$inferSelect;
type LeadActivityRow = typeof leadActivities.$inferSelect;

export class LeadRepository {
  constructor(private readonly db: Database) {}

  async hasBusinessMembership(
    businessId: string,
    accountId: string,
  ): Promise<boolean> {
    const [membership] = await this.db
      .select({ id: users.id })
      .from(users)
      .where(
        and(
          eq(users.businessId, businessId),
          eq(users.accountId, accountId),
          eq(users.isActive, true),
          eq(users.isDeleted, false),
        ),
      )
      .limit(1);

    return Boolean(membership);
  }

  async list(params: ListLeadsParams): Promise<{
    rows: LeadRecord[];
    total: number;
  }> {
    const conditions = [
      eq(leads.businessId, params.businessId),
      eq(leads.isDeleted, false),
    ];

    if (params.q) {
      const pattern = `%${params.q}%`;
      conditions.push(
        or(
          ilike(leads.name, pattern),
          ilike(leads.company, pattern),
          ilike(leads.email, pattern),
          ilike(leads.phone, pattern),
        )!,
      );
    }

    if (params.status) {
      conditions.push(eq(leads.status, params.status));
    }

    if (params.leadSource) {
      conditions.push(eq(leads.leadSource, params.leadSource));
    }

    if (params.from) {
      conditions.push(gte(leads.createdAt, params.from));
    }

    if (params.to) {
      conditions.push(lte(leads.createdAt, params.to));
    }

    const whereClause = and(...conditions);

    const [totalRow] = await this.db
      .select({ total: count() })
      .from(leads)
      .where(whereClause);

    const offset = (params.page - 1) * params.limit;
    const rows = await this.db
      .select()
      .from(leads)
      .where(whereClause)
      .orderBy(desc(leads.createdAt))
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map(mapLeadRow),
      total: Number(totalRow?.total ?? 0),
    };
  }

  async findById(
    businessId: string,
    leadId: string,
  ): Promise<LeadWithActivitiesRecord | null> {
    const [lead] = await this.db
      .select()
      .from(leads)
      .where(
        and(
          eq(leads.businessId, businessId),
          eq(leads.id, leadId),
          eq(leads.isDeleted, false),
        ),
      )
      .limit(1);

    if (!lead) return null;

    const activities = await this.db
      .select()
      .from(leadActivities)
      .where(
        and(
          eq(leadActivities.businessId, businessId),
          eq(leadActivities.leadId, leadId),
          eq(leadActivities.isDeleted, false),
        ),
      )
      .orderBy(desc(leadActivities.createdAt));

    return {
      ...mapLeadRow(lead),
      activities: activities.map(mapLeadActivityRow),
    };
  }

  async create(values: LeadInsertValues): Promise<LeadRecord> {
    const [row] = await this.db
      .insert(leads)
      .values({
        id: values.id,
        businessId: values.businessId,
        name: values.name,
        company: values.company ?? null,
        phone: values.phone ?? null,
        email: values.email ?? null,
        leadSource: values.leadSource ?? null,
        status: values.status ?? 'new',
        assignedTo: values.assignedTo ?? null,
        notes: values.notes ?? null,
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning();

    if (!row) {
      throw new Error('Failed to create lead');
    }

    return mapLeadRow(row);
  }

  async update(
    businessId: string,
    leadId: string,
    values: LeadUpdateValues,
  ): Promise<LeadRecord | null> {
    const [row] = await this.db
      .update(leads)
      .set({
        ...(values.name !== undefined ? { name: values.name } : {}),
        ...(values.company !== undefined ? { company: values.company } : {}),
        ...(values.phone !== undefined ? { phone: values.phone } : {}),
        ...(values.email !== undefined ? { email: values.email } : {}),
        ...(values.leadSource !== undefined
          ? { leadSource: values.leadSource }
          : {}),
        ...(values.status !== undefined ? { status: values.status } : {}),
        ...(values.assignedTo !== undefined
          ? { assignedTo: values.assignedTo }
          : {}),
        ...(values.notes !== undefined ? { notes: values.notes } : {}),
        ...(values.isDeleted !== undefined
          ? { isDeleted: values.isDeleted }
          : {}),
        ...(values.deletedAt !== undefined
          ? { deletedAt: values.deletedAt }
          : {}),
        updatedBy: values.updatedBy ?? null,
        updatedAt: sql`now()`,
        syncVersion: sql`${leads.syncVersion} + 1`,
      })
      .where(
        and(
          eq(leads.businessId, businessId),
          eq(leads.id, leadId),
          eq(leads.isDeleted, false),
        ),
      )
      .returning();

    return row ? mapLeadRow(row) : null;
  }

  async softDelete(
    businessId: string,
    leadId: string,
    updatedBy?: string,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(leads)
      .set({
        isDeleted: true,
        deletedAt: sql`now()`,
        updatedBy: updatedBy ?? null,
        updatedAt: sql`now()`,
        syncVersion: sql`${leads.syncVersion} + 1`,
      })
      .where(
        and(
          eq(leads.businessId, businessId),
          eq(leads.id, leadId),
          eq(leads.isDeleted, false),
        ),
      )
      .returning({ id: leads.id });

    return Boolean(row);
  }

  async createActivity(
    values: LeadActivityInsertValues,
  ): Promise<LeadActivityRecord> {
    const [row] = await this.db
      .insert(leadActivities)
      .values({
        businessId: values.businessId,
        leadId: values.leadId,
        type: values.type,
        notes: values.notes ?? null,
        addedBy: values.addedBy ?? null,
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning();

    if (!row) {
      throw new Error('Failed to create lead activity');
    }

    return mapLeadActivityRow(row);
  }
}

function mapLeadRow(row: LeadRow): LeadRecord {
  return {
    id: row.id,
    business_id: row.businessId,
    name: row.name,
    company: row.company,
    phone: row.phone,
    email: row.email,
    lead_source: row.leadSource,
    status: row.status,
    assigned_to: row.assignedTo,
    notes: row.notes,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}

function mapLeadActivityRow(row: LeadActivityRow): LeadActivityRecord {
  return {
    id: row.id,
    lead_id: row.leadId,
    business_id: row.businessId,
    type: row.type,
    notes: row.notes,
    added_by: row.addedBy,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}
