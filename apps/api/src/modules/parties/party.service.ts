import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { resolvePartyPricingTier } from '../../shared/pricing/pricing-tier';
import { PartyRepository } from './party.repository';
import type {
  CreatePartyBody,
  ListPartiesQuery,
  UpdatePartyBody,
} from './party.schema';
import type {
  PartyDeleteAction,
  PartyDeleteStatus,
  PartyRecord,
} from './party.types';
import {
  normalizeGstin,
  normalizeMobile,
  normalizeMoney,
  resolveStateCode,
  validateGstin,
  validateNormalizedMobile,
} from './party.utils';

export class PartyService {
  private readonly repository: PartyRepository;

  constructor() {
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.repository = new PartyRepository(db);
  }

  async listParties(
    businessId: string,
    accountId: string,
    query: ListPartiesQuery,
  ): Promise<{
    data: PartyRecord[];
    meta: { page: number; limit: number; total: number };
  }> {
    await this.assertBusinessAccess(businessId, accountId);

    const result = await this.repository.list({
      businessId,
      page: query.page,
      limit: query.limit,
      q: query.q,
      partyType: query.party_type,
      isActive: query.is_active,
      sort: query.sort,
      order: query.order,
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

  async getParty(
    businessId: string,
    accountId: string,
    partyId: string,
  ): Promise<PartyRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const party = await this.repository.findById(businessId, partyId);
    if (!party) {
      throw new AppError('NOT_FOUND', 'Party not found', 404);
    }

    return party;
  }

  async createParty(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreatePartyBody,
  ): Promise<PartyRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const mobile = normalizeMobile(input.mobile);
    if (!validateNormalizedMobile(mobile)) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        mobile: ['Phone must be exactly 10 digits'],
      });
    }

    const gstin = normalizeGstin(input.gstin);
    if (!validateGstin(gstin)) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        gstin: ['Invalid GSTIN format'],
      });
    }

    if (mobile) {
      await this.assertMobileAvailable(businessId, mobile);
    }

    if (gstin) {
      await this.assertGstinAvailable(businessId, gstin);
    }

    return this.repository.create({
      businessId,
      name: input.name.trim(),
      mobile,
      email: input.email?.trim() || null,
      partyType: input.party_type,
      partyCategory: input.party_category ?? null,
      pricingTier: resolvePartyPricingTier(input) ?? 'tier_1',
      gstin,
      stateCode: resolveStateCode(input.state, input.state_code),
      areaId: input.area_id ?? null,
      creditLimit: normalizeMoney(input.credit_limit),
      openingBalance: normalizeMoney(input.opening_balance),
      notes: input.notes?.trim() || null,
      isActive: input.is_active ?? true,
      createdBy: userId ?? null,
      updatedBy: userId ?? null,
    });
  }

  async updateParty(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    partyId: string,
    input: UpdatePartyBody,
  ): Promise<PartyRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findById(businessId, partyId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Party not found', 404);
    }

    const mobile =
      input.mobile !== undefined ? normalizeMobile(input.mobile) : undefined;

    if (mobile !== undefined && !validateNormalizedMobile(mobile)) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        mobile: ['Phone must be exactly 10 digits'],
      });
    }

    const gstin =
      input.gstin !== undefined ? normalizeGstin(input.gstin) : undefined;

    if (gstin !== undefined && !validateGstin(gstin)) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        gstin: ['Invalid GSTIN format'],
      });
    }

    if (mobile) {
      await this.assertMobileAvailable(businessId, mobile, partyId);
    }

    if (gstin) {
      await this.assertGstinAvailable(businessId, gstin, partyId);
    }

    const resolvedPricingTier = resolvePartyPricingTier(input);

    const updated = await this.repository.update(businessId, partyId, {
      ...(input.name !== undefined ? { name: input.name.trim() } : {}),
      ...(mobile !== undefined ? { mobile } : {}),
      ...(input.email !== undefined
        ? { email: input.email?.trim() || null }
        : {}),
      ...(input.party_type !== undefined
        ? { partyType: input.party_type }
        : {}),
      ...(input.party_category !== undefined
        ? { partyCategory: input.party_category ?? null }
        : {}),
      ...(resolvedPricingTier !== undefined
        ? { pricingTier: resolvedPricingTier }
        : {}),
      ...(gstin !== undefined ? { gstin } : {}),
      ...(input.state !== undefined || input.state_code !== undefined
        ? {
            stateCode: resolveStateCode(input.state, input.state_code),
          }
        : {}),
      ...(input.area_id !== undefined ? { areaId: input.area_id ?? null } : {}),
      ...(input.credit_limit !== undefined
        ? { creditLimit: normalizeMoney(input.credit_limit) }
        : {}),
      ...(input.opening_balance !== undefined
        ? { openingBalance: normalizeMoney(input.opening_balance) }
        : {}),
      ...(input.notes !== undefined
        ? { notes: input.notes?.trim() || null }
        : {}),
      ...(input.is_active !== undefined ? { isActive: input.is_active } : {}),
      updatedBy: userId ?? null,
    });

    if (!updated) {
      throw new AppError('NOT_FOUND', 'Party not found', 404);
    }

    return updated;
  }

  async getPartyDeleteStatus(
    businessId: string,
    accountId: string,
    partyId: string,
  ): Promise<PartyDeleteStatus> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findById(businessId, partyId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Party not found', 404);
    }

    const references = await this.repository.countDeleteReferences(
      businessId,
      partyId,
    );

    const hasReferences = Object.values(references).some((count) => count > 0);
    if (!hasReferences) {
      return { canDelete: true };
    }

    return { canDelete: false, references };
  }

  async deleteParty(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    partyId: string,
  ): Promise<PartyDeleteAction> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findById(businessId, partyId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Party not found', 404);
    }

    const references = await this.repository.countDeleteReferences(
      businessId,
      partyId,
    );

    const hasReferences = Object.values(references).some((count) => count > 0);

    if (!hasReferences) {
      const deleted = await this.repository.softDelete(
        businessId,
        partyId,
        userId ?? null,
      );

      if (!deleted) {
        throw new AppError('NOT_FOUND', 'Party not found', 404);
      }

      return 'deleted';
    }

    const deactivated = await this.repository.update(businessId, partyId, {
      isActive: false,
      updatedBy: userId ?? null,
    });

    if (!deactivated) {
      throw new AppError('NOT_FOUND', 'Party not found', 404);
    }

    return 'deactivated';
  }

  private async assertBusinessAccess(
    businessId: string,
    accountId: string,
  ): Promise<void> {
    const hasAccess = await this.repository.hasBusinessMembership(
      businessId,
      accountId,
    );

    if (!hasAccess) {
      throw new AppError(
        'FORBIDDEN',
        'You do not have access to this business',
        403,
      );
    }
  }

  private async assertMobileAvailable(
    businessId: string,
    mobile: string,
    excludePartyId?: string,
  ): Promise<void> {
    const conflictId = await this.repository.findActiveMobileConflict(
      businessId,
      mobile,
      excludePartyId,
    );

    if (conflictId) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        mobile: ['This mobile number is already registered to another party'],
      });
    }
  }

  private async assertGstinAvailable(
    businessId: string,
    gstin: string,
    excludePartyId?: string,
  ): Promise<void> {
    const conflictId = await this.repository.findActiveGstinConflict(
      businessId,
      gstin,
      excludePartyId,
    );

    if (conflictId) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        gstin: ['This GSTIN is already registered to another party'],
      });
    }
  }
}
