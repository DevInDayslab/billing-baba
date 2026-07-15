import { and, count, desc, eq, gte, ilike, lte, or, sql } from 'drizzle-orm';
import type { Database } from '../../../db/client';
import { contactActivities, contacts } from '../../../db/schema/crm/tables';
import { users } from '../../../db/schema/identity/tables';
import type {
  ContactActivityInsertValues,
  ContactActivityRecord,
  ContactInsertValues,
  ContactRecord,
  ContactUpdateValues,
  ContactWithActivitiesRecord,
  ListContactsParams,
} from '../contact.types';

type ContactRow = typeof contacts.$inferSelect;
type ContactActivityRow = typeof contactActivities.$inferSelect;

export class ContactRepository {
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

  async list(params: ListContactsParams): Promise<{
    rows: ContactRecord[];
    total: number;
  }> {
    const conditions = [
      eq(contacts.businessId, params.businessId),
      eq(contacts.isDeleted, false),
    ];

    if (params.q) {
      const pattern = `%${params.q}%`;
      conditions.push(
        or(
          ilike(contacts.name, pattern),
          ilike(contacts.accountName, pattern),
          ilike(contacts.email, pattern),
          ilike(contacts.phone, pattern),
        )!,
      );
    }

    if (params.accountName) {
      conditions.push(eq(contacts.accountName, params.accountName));
    }

    if (params.assignedTo) {
      conditions.push(eq(contacts.assignedTo, params.assignedTo));
    }

    if (params.from) {
      conditions.push(gte(contacts.createdAt, params.from));
    }

    if (params.to) {
      conditions.push(lte(contacts.createdAt, params.to));
    }

    const whereClause = and(...conditions);

    const [totalRow] = await this.db
      .select({ total: count() })
      .from(contacts)
      .where(whereClause);

    const offset = (params.page - 1) * params.limit;
    const rows = await this.db
      .select()
      .from(contacts)
      .where(whereClause)
      .orderBy(desc(contacts.createdAt))
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map(mapContactRow),
      total: Number(totalRow?.total ?? 0),
    };
  }

  async findById(
    businessId: string,
    contactId: string,
  ): Promise<ContactWithActivitiesRecord | null> {
    const [contact] = await this.db
      .select()
      .from(contacts)
      .where(
        and(
          eq(contacts.businessId, businessId),
          eq(contacts.id, contactId),
          eq(contacts.isDeleted, false),
        ),
      )
      .limit(1);

    if (!contact) return null;

    const activities = await this.db
      .select()
      .from(contactActivities)
      .where(
        and(
          eq(contactActivities.businessId, businessId),
          eq(contactActivities.contactId, contactId),
          eq(contactActivities.isDeleted, false),
        ),
      )
      .orderBy(desc(contactActivities.createdAt));

    return {
      ...mapContactRow(contact),
      activities: activities.map(mapContactActivityRow),
    };
  }

  async create(values: ContactInsertValues): Promise<ContactRecord> {
    const [row] = await this.db
      .insert(contacts)
      .values({
        id: values.id,
        businessId: values.businessId,
        name: values.name,
        firstName: values.firstName ?? null,
        lastName: values.lastName ?? null,
        salutation: values.salutation ?? null,
        accountName: values.accountName ?? null,
        phone: values.phone ?? null,
        email: values.email ?? null,
        assignedTo: values.assignedTo ?? null,
        title: values.title ?? null,
        description: values.description ?? null,
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning();

    if (!row) {
      throw new Error('Failed to create contact');
    }

    return mapContactRow(row);
  }

  async update(
    businessId: string,
    contactId: string,
    values: ContactUpdateValues,
  ): Promise<ContactRecord | null> {
    const [row] = await this.db
      .update(contacts)
      .set({
        ...(values.name !== undefined ? { name: values.name } : {}),
        ...(values.firstName !== undefined
          ? { firstName: values.firstName }
          : {}),
        ...(values.lastName !== undefined ? { lastName: values.lastName } : {}),
        ...(values.salutation !== undefined
          ? { salutation: values.salutation }
          : {}),
        ...(values.accountName !== undefined
          ? { accountName: values.accountName }
          : {}),
        ...(values.phone !== undefined ? { phone: values.phone } : {}),
        ...(values.email !== undefined ? { email: values.email } : {}),
        ...(values.assignedTo !== undefined
          ? { assignedTo: values.assignedTo }
          : {}),
        ...(values.title !== undefined ? { title: values.title } : {}),
        ...(values.description !== undefined
          ? { description: values.description }
          : {}),
        ...(values.isDeleted !== undefined
          ? { isDeleted: values.isDeleted }
          : {}),
        ...(values.deletedAt !== undefined
          ? { deletedAt: values.deletedAt }
          : {}),
        updatedBy: values.updatedBy ?? null,
        updatedAt: sql`now()`,
        syncVersion: sql`${contacts.syncVersion} + 1`,
      })
      .where(
        and(
          eq(contacts.businessId, businessId),
          eq(contacts.id, contactId),
          eq(contacts.isDeleted, false),
        ),
      )
      .returning();

    return row ? mapContactRow(row) : null;
  }

  async softDelete(
    businessId: string,
    contactId: string,
    updatedBy?: string,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(contacts)
      .set({
        isDeleted: true,
        deletedAt: sql`now()`,
        updatedBy: updatedBy ?? null,
        updatedAt: sql`now()`,
        syncVersion: sql`${contacts.syncVersion} + 1`,
      })
      .where(
        and(
          eq(contacts.businessId, businessId),
          eq(contacts.id, contactId),
          eq(contacts.isDeleted, false),
        ),
      )
      .returning({ id: contacts.id });

    return Boolean(row);
  }

  async createActivity(
    values: ContactActivityInsertValues,
  ): Promise<ContactActivityRecord> {
    const [row] = await this.db
      .insert(contactActivities)
      .values({
        businessId: values.businessId,
        contactId: values.contactId,
        type: values.type,
        notes: values.notes ?? null,
        addedBy: values.addedBy ?? null,
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning();

    if (!row) {
      throw new Error('Failed to create contact activity');
    }

    return mapContactActivityRow(row);
  }
}

function mapContactRow(row: ContactRow): ContactRecord {
  return {
    id: row.id,
    business_id: row.businessId,
    name: row.name,
    first_name: row.firstName,
    last_name: row.lastName,
    salutation: row.salutation,
    account_name: row.accountName,
    phone: row.phone,
    email: row.email,
    assigned_to: row.assignedTo,
    title: row.title,
    description: row.description,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}

function mapContactActivityRow(row: ContactActivityRow): ContactActivityRecord {
  return {
    id: row.id,
    contact_id: row.contactId,
    business_id: row.businessId,
    type: row.type,
    notes: row.notes,
    added_by: row.addedBy,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}
