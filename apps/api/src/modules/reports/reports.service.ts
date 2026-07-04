import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { buildPaginationMeta } from '../../shared/http/pagination';
import { BusinessMembershipRepository } from '../../shared/repositories/business-membership.repository';
import { ReportsRepository } from './reports.repository';
import type {
  PartyStatementQuery,
  ReportBaseQuery,
  ReportDateQuery,
} from './reports.schema';
import type {
  AllTransactionsPayload,
  DayBookPayload,
  Gstr3bPayload,
  GstrReportPayload,
  LowStockPayload,
  PartyOutstandingPayload,
  PartyStatementPayload,
  ProfitLossPayload,
  PurchaseReportPayload,
  SaleReportPayload,
  StockSummaryPayload,
} from './reports.types';

export class ReportsService {
  private readonly repository: ReportsRepository;
  private readonly membershipRepository: BusinessMembershipRepository;

  constructor() {
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.repository = new ReportsRepository(db);
    this.membershipRepository = new BusinessMembershipRepository(db);
  }

  private async assertBusinessAccess(
    businessId: string,
    accountId: string,
  ): Promise<void> {
    const hasAccess = await this.membershipRepository.hasBusinessMembership(
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

  async getSaleReport(
    businessId: string,
    accountId: string,
    query: ReportBaseQuery,
  ) {
    await this.assertBusinessAccess(businessId, accountId);
    const { payload, total } = await this.repository.getSaleReport(
      businessId,
      query,
    );
    return {
      data: payload,
      meta: buildPaginationMeta({
        page: query.page,
        limit: query.limit,
        total,
      }),
    };
  }

  async getPurchaseReport(
    businessId: string,
    accountId: string,
    query: ReportBaseQuery,
  ) {
    await this.assertBusinessAccess(businessId, accountId);
    const { payload, total } = await this.repository.getPurchaseReport(
      businessId,
      query,
    );
    return {
      data: payload,
      meta: buildPaginationMeta({
        page: query.page,
        limit: query.limit,
        total,
      }),
    };
  }

  async getStockSummary(
    businessId: string,
    accountId: string,
    query: ReportBaseQuery,
  ) {
    await this.assertBusinessAccess(businessId, accountId);
    const { payload, total } = await this.repository.getStockSummary(
      businessId,
      query,
    );
    return {
      data: payload,
      meta: buildPaginationMeta({
        page: query.page,
        limit: query.limit,
        total,
      }),
    };
  }

  async getLowStock(
    businessId: string,
    accountId: string,
    query: ReportBaseQuery,
  ) {
    await this.assertBusinessAccess(businessId, accountId);
    const { payload, total } = await this.repository.getLowStock(
      businessId,
      query,
    );
    return {
      data: payload,
      meta: buildPaginationMeta({
        page: query.page,
        limit: query.limit,
        total,
      }),
    };
  }

  async getPartyOutstanding(
    businessId: string,
    accountId: string,
    query: ReportBaseQuery,
  ) {
    await this.assertBusinessAccess(businessId, accountId);
    const { payload, total } = await this.repository.getPartyOutstanding(
      businessId,
      query,
    );
    return {
      data: payload,
      meta: buildPaginationMeta({
        page: query.page,
        limit: query.limit,
        total,
      }),
    };
  }

  async getPartyStatement(
    businessId: string,
    accountId: string,
    query: PartyStatementQuery,
  ): Promise<PartyStatementPayload> {
    await this.assertBusinessAccess(businessId, accountId);
    return this.repository.getPartyStatement(businessId, query);
  }

  async getDayBook(
    businessId: string,
    accountId: string,
    query: ReportDateQuery,
  ): Promise<DayBookPayload> {
    await this.assertBusinessAccess(businessId, accountId);
    return this.repository.getDayBook(businessId, query);
  }

  async getAllTransactions(
    businessId: string,
    accountId: string,
    query: ReportBaseQuery,
  ) {
    await this.assertBusinessAccess(businessId, accountId);
    const { payload, total } = await this.repository.getAllTransactions(
      businessId,
      query,
    );
    return {
      data: payload,
      meta: buildPaginationMeta({
        page: query.page,
        limit: query.limit,
        total,
      }),
    };
  }

  async getProfitLoss(
    businessId: string,
    accountId: string,
    query: ReportBaseQuery,
  ): Promise<ProfitLossPayload> {
    await this.assertBusinessAccess(businessId, accountId);
    return this.repository.getProfitLoss(businessId, query);
  }

  async getGstr1(
    businessId: string,
    accountId: string,
    query: ReportBaseQuery,
  ): Promise<GstrReportPayload> {
    await this.assertBusinessAccess(businessId, accountId);
    return this.repository.getGstr1(businessId, query);
  }

  async getGstr2(
    businessId: string,
    accountId: string,
    query: ReportBaseQuery,
  ): Promise<GstrReportPayload> {
    await this.assertBusinessAccess(businessId, accountId);
    return this.repository.getGstr2(businessId, query);
  }

  async getGstr3b(
    businessId: string,
    accountId: string,
    query: ReportBaseQuery,
  ): Promise<Gstr3bPayload> {
    await this.assertBusinessAccess(businessId, accountId);
    return this.repository.getGstr3b(businessId, query);
  }
}
