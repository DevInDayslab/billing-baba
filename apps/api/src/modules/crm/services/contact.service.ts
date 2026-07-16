import { getDb } from '../../../db/client';
import { AppError } from '../../../shared/errors/app-error';
import type {
  CreateContactActivityBody,
  CreateContactBody,
  ListContactsQuery,
  UpdateContactBody,
} from '../contact.schema';
import type {
  ContactActivityRecord,
  ContactRecord,
  ContactWithActivitiesRecord,
} from '../contact.types';
import { ContactRepository } from '../db/contact.repository';

export class ContactService {
  private readonly repository: ContactRepository;

  constructor() {
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.repository = new ContactRepository(db);
  }

  async listContacts(
    businessId: string,
    accountId: string,
    query: ListContactsQuery,
  ): Promise<{
    data: ContactRecord[];
    meta: { page: number; limit: number; total: number };
  }> {
    await this.assertBusinessAccess(businessId, accountId);

    const result = await this.repository.list({
      businessId,
      page: query.page,
      limit: query.limit,
      q: query.q,
      accountName: query.account_name,
      assignedTo: query.assigned_to,
      from: query.from ? new Date(query.from) : undefined,
      to: query.to ? new Date(query.to) : undefined,
    });

    return {
      data: result.rows,
      meta: {
        page: query.page,
        limit: query.limit,
        total: result.total,
      },
    };
  }

  async getContact(
    businessId: string,
    accountId: string,
    contactId: string,
  ): Promise<ContactWithActivitiesRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const contact = await this.repository.findById(businessId, contactId);
    if (!contact) {
      throw new AppError('NOT_FOUND', 'Contact not found', 404);
    }

    return contact;
  }

  async createContact(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreateContactBody,
  ): Promise<ContactRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    return this.repository.create({
      id: input.id,
      businessId,
      name: input.name,
      firstName: input.first_name ?? null,
      lastName: input.last_name ?? null,
      salutation: input.salutation ?? null,
      accountName: input.account_name ?? null,
      phone: input.phone,
      email: input.email ?? null,
      assignedTo: input.assigned_to ?? null,
      title: input.title ?? null,
      description: input.description ?? null,
      createdBy: userId ?? null,
      updatedBy: userId ?? null,
    });
  }

  async updateContact(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    contactId: string,
    input: UpdateContactBody,
  ): Promise<ContactRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const updated = await this.repository.update(businessId, contactId, {
      name: input.name,
      firstName: input.first_name,
      lastName: input.last_name,
      salutation: input.salutation,
      accountName: input.account_name,
      phone: input.phone,
      email: input.email,
      assignedTo: input.assigned_to,
      title: input.title,
      description: input.description,
      updatedBy: userId ?? null,
    });

    if (!updated) {
      throw new AppError('NOT_FOUND', 'Contact not found', 404);
    }

    return updated;
  }

  async deleteContact(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    contactId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);

    const deleted = await this.repository.softDelete(
      businessId,
      contactId,
      userId,
    );
    if (!deleted) {
      throw new AppError('NOT_FOUND', 'Contact not found', 404);
    }
  }

  async addActivity(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    contactId: string,
    input: CreateContactActivityBody,
  ): Promise<ContactActivityRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const contact = await this.repository.findById(businessId, contactId);
    if (!contact) {
      throw new AppError('NOT_FOUND', 'Contact not found', 404);
    }

    return this.repository.createActivity({
      businessId,
      contactId,
      type: input.type,
      notes: input.notes ?? null,
      addedBy: input.added_by ?? null,
      createdBy: userId ?? null,
      updatedBy: userId ?? null,
    });
  }

  private async assertBusinessAccess(
    businessId: string,
    accountId: string,
  ): Promise<void> {
    const allowed = await this.repository.hasBusinessMembership(
      businessId,
      accountId,
    );
    if (!allowed) {
      throw new AppError('FORBIDDEN', 'Access denied for this business', 403);
    }
  }
}
