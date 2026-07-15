import { getDb } from '../../../db/client';
import { AppError } from '../../../shared/errors/app-error';
import { LeadRepository } from '../db/lead.repository';
import type {
  CreateLeadActivityBody,
  CreateLeadBody,
  ListLeadsQuery,
  UpdateLeadBody,
} from '../lead.schema';
import type { LeadActivityRecord, LeadRecord, LeadWithActivitiesRecord } from '../lead.types';

export class LeadService {
  private readonly repository: LeadRepository;

  constructor() {
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.repository = new LeadRepository(db);
  }

  async listLeads(
    businessId: string,
    accountId: string,
    query: ListLeadsQuery,
  ): Promise<{
    data: LeadRecord[];
    meta: { page: number; limit: number; total: number };
  }> {
    await this.assertBusinessAccess(businessId, accountId);

    const result = await this.repository.list({
      businessId,
      page: query.page,
      limit: query.limit,
      q: query.q,
      status: query.status,
      leadSource: query.lead_source,
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

  async getLead(
    businessId: string,
    accountId: string,
    leadId: string,
  ): Promise<LeadWithActivitiesRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const lead = await this.repository.findById(businessId, leadId);
    if (!lead) {
      throw new AppError('NOT_FOUND', 'Lead not found', 404);
    }

    return lead;
  }

  async createLead(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreateLeadBody,
  ): Promise<LeadRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    return this.repository.create({
      id: input.id,
      businessId,
      name: input.name,
      company: input.company ?? null,
      phone: input.phone,
      email: input.email ?? null,
      leadSource: input.lead_source ?? null,
      status: input.status,
      assignedTo: input.assigned_to ?? null,
      notes: input.notes ?? null,
      createdBy: userId ?? null,
      updatedBy: userId ?? null,
    });
  }

  async updateLead(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    leadId: string,
    input: UpdateLeadBody,
  ): Promise<LeadRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const updated = await this.repository.update(businessId, leadId, {
      name: input.name,
      company: input.company,
      phone: input.phone,
      email: input.email,
      leadSource: input.lead_source,
      status: input.status,
      assignedTo: input.assigned_to,
      notes: input.notes,
      updatedBy: userId ?? null,
    });

    if (!updated) {
      throw new AppError('NOT_FOUND', 'Lead not found', 404);
    }

    return updated;
  }

  async deleteLead(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    leadId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);

    const deleted = await this.repository.softDelete(
      businessId,
      leadId,
      userId,
    );
    if (!deleted) {
      throw new AppError('NOT_FOUND', 'Lead not found', 404);
    }
  }

  async addActivity(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    leadId: string,
    input: CreateLeadActivityBody,
  ): Promise<LeadActivityRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const lead = await this.repository.findById(businessId, leadId);
    if (!lead) {
      throw new AppError('NOT_FOUND', 'Lead not found', 404);
    }

    return this.repository.createActivity({
      businessId,
      leadId,
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
