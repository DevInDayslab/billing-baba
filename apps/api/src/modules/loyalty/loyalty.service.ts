import type { Database } from '../../db/client';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { parseMoney } from '../inventory/inventory.utils';
import { PartyRepository } from '../parties/party.repository';
import type { ListLoyaltyTransactionsQuery } from './loyalty.schema';
import { LoyaltyRepository } from './loyalty.repository';
import type {
  LoyaltyRulesRecord,
  LoyaltyTransactionRecord,
  PartyLoyaltyBalanceRecord,
  PartyType,
  SaleLoyaltyResult,
} from './loyalty.types';
import {
  DEFAULT_RUPEES_PER_POINT,
  RUPEES_PER_REDEEMED_POINT,
  formatLoyaltyPoints,
  isEligiblePartyType,
  isLoyaltyEarnDocumentType,
  parseLoyaltyPoints,
  pointsEarnedForSpend,
} from './loyalty.utils';

type DbTransaction = Parameters<Parameters<Database['transaction']>[0]>[0];

export type ApplySaleLoyaltyParams = {
  businessId: string;
  partyId: string;
  partyType: PartyType;
  documentId: string;
  documentType: string;
  totalAmount: string;
  loyaltyPointsRedeemed?: string;
  userId?: string;
};

export class LoyaltyService {
  private readonly db: Database;
  private readonly repository: LoyaltyRepository;
  private readonly partyRepository: PartyRepository;

  constructor(db?: Database) {
    const resolvedDb = db ?? getDb();
    if (!resolvedDb) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.db = resolvedDb;
    this.repository = new LoyaltyRepository(resolvedDb);
    this.partyRepository = new PartyRepository(resolvedDb);
  }

  async getPartyBalance(
    businessId: string,
    accountId: string,
    partyId: string,
  ): Promise<PartyLoyaltyBalanceRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const partyExists = await this.repository.partyExists(
      this.db,
      businessId,
      partyId,
    );
    if (!partyExists) {
      throw new AppError('NOT_FOUND', 'Party not found', 404);
    }

    const balance = await this.repository.getBalance(businessId, partyId);
    return this.toBalanceRecord(partyId, balance);
  }

  async listPartyTransactions(
    businessId: string,
    accountId: string,
    partyId: string,
    query: ListLoyaltyTransactionsQuery,
  ): Promise<{
    data: LoyaltyTransactionRecord[];
    meta: { page: number; limit: number; total: number };
  }> {
    await this.assertBusinessAccess(businessId, accountId);

    const partyExists = await this.repository.partyExists(
      this.db,
      businessId,
      partyId,
    );
    if (!partyExists) {
      throw new AppError('NOT_FOUND', 'Party not found', 404);
    }

    const result = await this.repository.listTransactions({
      businessId,
      partyId,
      page: query.page,
      limit: query.limit,
      from: query.from,
      to: query.to,
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

  async getRules(
    businessId: string,
    accountId: string,
  ): Promise<LoyaltyRulesRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    const rules = await this.repository.findActiveRules(businessId);
    return this.toRulesRecord(rules);
  }

  async updateRules(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: { rupees_per_point?: string; is_active?: boolean },
  ): Promise<LoyaltyRulesRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findActiveRules(businessId);
    if (!existing) {
      const created = await this.repository.createRules(businessId, {
        rupeesPerPoint: input.rupees_per_point ?? formatLoyaltyPoints(
          DEFAULT_RUPEES_PER_POINT,
        ),
        isActive: input.is_active ?? true,
        userId,
      });
      return this.toRulesRecord(created);
    }

    const updated = await this.repository.updateRules(existing.id, {
      rupeesPerPoint: input.rupees_per_point,
      isActive: input.is_active,
      userId,
    });
    return this.toRulesRecord(updated);
  }

  async resolveRupeesPerPoint(businessId: string): Promise<number> {
    const rules = await this.repository.findActiveRules(businessId);
    if (!rules || !rules.isActive) {
      return DEFAULT_RUPEES_PER_POINT;
    }
    const value = parseLoyaltyPoints(rules.rupeesPerPoint);
    return value > 0 ? value : DEFAULT_RUPEES_PER_POINT;
  }

  validateRedemption(params: {
    partyType: PartyType;
    availablePoints: number;
    pointsToRedeem: number;
    documentTotal: number;
  }): void {
    if (params.pointsToRedeem <= 0) {
      return;
    }

    if (!isEligiblePartyType(params.partyType)) {
      throw new AppError(
        'LOYALTY_NOT_ELIGIBLE',
        'Loyalty points cannot be redeemed for this party',
        422,
      );
    }

    if (params.pointsToRedeem > params.availablePoints) {
      throw new AppError(
        'INSUFFICIENT_LOYALTY_POINTS',
        'Insufficient loyalty points balance',
        422,
        {
          available: [formatLoyaltyPoints(params.availablePoints)],
          requested: [formatLoyaltyPoints(params.pointsToRedeem)],
        },
      );
    }

    const maxRedeemable = Math.min(
      params.availablePoints,
      params.documentTotal / RUPEES_PER_REDEEMED_POINT,
    );
    if (params.pointsToRedeem > maxRedeemable) {
      throw new AppError(
        'LOYALTY_REDEMPTION_EXCEEDS_TOTAL',
        'Loyalty redemption cannot exceed the invoice total',
        422,
        {
          max_redeemable: [formatLoyaltyPoints(maxRedeemable)],
          requested: [formatLoyaltyPoints(params.pointsToRedeem)],
        },
      );
    }
  }

  async applySaleLoyalty(
    tx: DbTransaction,
    params: ApplySaleLoyaltyParams,
  ): Promise<SaleLoyaltyResult | null> {
    if (!params.partyId || !isLoyaltyEarnDocumentType(params.documentType)) {
      return null;
    }

    const pointsToRedeem = parseLoyaltyPoints(params.loyaltyPointsRedeemed);
    if (!isEligiblePartyType(params.partyType)) {
      if (pointsToRedeem > 0) {
        throw new AppError(
          'LOYALTY_NOT_ELIGIBLE',
          'Loyalty points cannot be redeemed for this party',
          422,
        );
      }
      return null;
    }

    const documentTotal = parseMoney(params.totalAmount);
    const rupeesPerPoint = await this.resolveRupeesPerPoint(params.businessId);

    let balance =
      (await this.repository.findBalanceForUpdate(
        tx,
        params.businessId,
        params.partyId,
      )) ??
      (await this.repository.createBalance(tx, {
        businessId: params.businessId,
        partyId: params.partyId,
        pointsEarned: formatLoyaltyPoints(0),
        pointsAvailable: formatLoyaltyPoints(0),
        createdBy: params.userId ?? null,
        updatedBy: params.userId ?? null,
      }));

    const availablePoints = parseLoyaltyPoints(balance.pointsAvailable);
    this.validateRedemption({
      partyType: params.partyType,
      availablePoints,
      pointsToRedeem,
      documentTotal,
    });

    const redemptionValue = pointsToRedeem * RUPEES_PER_REDEEMED_POINT;
    const spendAmount = Math.max(documentTotal - redemptionValue, 0);
    const earnedPoints = pointsEarnedForSpend(spendAmount, rupeesPerPoint);
    const newAvailable = availablePoints - pointsToRedeem + earnedPoints;
    const newEarned =
      parseLoyaltyPoints(balance.pointsEarned) + earnedPoints;

    balance = await this.repository.updateBalance(tx, balance.id, {
      pointsEarned: formatLoyaltyPoints(newEarned),
      pointsAvailable: formatLoyaltyPoints(newAvailable),
      updatedBy: params.userId ?? null,
    });

    if (pointsToRedeem > 0) {
      const balanceAfterRedeem = availablePoints - pointsToRedeem;
      await this.repository.insertTransaction(tx, {
        businessId: params.businessId,
        partyId: params.partyId,
        transactionType: 'redeem',
        points: formatLoyaltyPoints(pointsToRedeem),
        balanceAfter: formatLoyaltyPoints(balanceAfterRedeem),
        referenceId: params.documentId,
        referenceType: 'sales_documents',
        description: 'Points redeemed on sale',
        createdBy: params.userId ?? null,
      });
    }

    if (earnedPoints > 0) {
      await this.repository.insertTransaction(tx, {
        businessId: params.businessId,
        partyId: params.partyId,
        transactionType: 'earn',
        points: formatLoyaltyPoints(earnedPoints),
        balanceAfter: balance.pointsAvailable,
        referenceId: params.documentId,
        referenceType: 'sales_documents',
        spendAmount: formatLoyaltyPoints(spendAmount),
        rupeesPerPoint: formatLoyaltyPoints(rupeesPerPoint),
        description: 'Points earned on sale',
        createdBy: params.userId ?? null,
      });
    }

    return {
      earned_points: formatLoyaltyPoints(earnedPoints),
      redeemed_points: formatLoyaltyPoints(pointsToRedeem),
      points_available: balance.pointsAvailable,
    };
  }

  private toBalanceRecord(
    partyId: string,
    balance: {
      pointsEarned: string;
      pointsAvailable: string;
    } | null,
  ): PartyLoyaltyBalanceRecord {
    return {
      party_id: partyId,
      points_earned: balance?.pointsEarned ?? formatLoyaltyPoints(0),
      points_available: balance?.pointsAvailable ?? formatLoyaltyPoints(0),
    };
  }

  private toRulesRecord(
    rules: {
      id: string;
      rupeesPerPoint: string;
      isActive: boolean;
      updatedAt: Date;
    } | null,
  ): LoyaltyRulesRecord {
    if (!rules) {
      return {
        id: null,
        rupees_per_point: formatLoyaltyPoints(DEFAULT_RUPEES_PER_POINT),
        is_active: true,
        updated_at: null,
      };
    }

    return {
      id: rules.id,
      rupees_per_point: rules.rupeesPerPoint,
      is_active: rules.isActive,
      updated_at: rules.updatedAt.toISOString(),
    };
  }

  private async assertBusinessAccess(
    businessId: string,
    accountId: string,
  ): Promise<void> {
    const hasAccess = await this.partyRepository.hasBusinessMembership(
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
}
