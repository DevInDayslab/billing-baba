import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { buildPaginationMeta } from '../../shared/http/pagination';
import { BusinessMembershipRepository } from '../../shared/repositories/business-membership.repository';
import { ReportsRepository } from './reports.repository';
import type {
  LoanStatementQuery,
  PartyStatementQuery,
  ReportBaseQuery,
  ReportDateQuery,
  ReportExtendedQuery,
} from './reports.schema';

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

  private async paginated(
    businessId: string,
    accountId: string,
    query: ReportBaseQuery | ReportExtendedQuery,
    fetch: (
      businessId: string,
      query: ReportExtendedQuery,
    ) => Promise<{ payload: object; total: number }>,
  ) {
    await this.assertBusinessAccess(businessId, accountId);
    const { payload, total } = await fetch(
      businessId,
      query as ReportExtendedQuery,
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

  getSaleReport(businessId: string, accountId: string, query: ReportBaseQuery) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getSaleReport(id, q),
    );
  }

  getPurchaseReport(
    businessId: string,
    accountId: string,
    query: ReportBaseQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getPurchaseReport(id, q),
    );
  }

  getStockSummary(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getStockSummary(id, q),
    );
  }

  getLowStock(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getLowStock(id, q),
    );
  }

  getPartyOutstanding(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getPartyOutstanding(id, q),
    );
  }

  async getPartyStatement(
    businessId: string,
    accountId: string,
    query: PartyStatementQuery,
  ) {
    await this.assertBusinessAccess(businessId, accountId);
    return this.repository.getPartyStatement(businessId, query);
  }

  async getDayBook(
    businessId: string,
    accountId: string,
    query: ReportDateQuery,
  ) {
    await this.assertBusinessAccess(businessId, accountId);
    return this.repository.getDayBook(businessId, query);
  }

  getAllTransactions(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getAllTransactions(id, q),
    );
  }

  async getProfitLoss(
    businessId: string,
    accountId: string,
    query: ReportBaseQuery,
  ) {
    await this.assertBusinessAccess(businessId, accountId);
    return this.repository.getProfitLoss(businessId, query);
  }

  async getGstr1(
    businessId: string,
    accountId: string,
    query: ReportBaseQuery,
  ) {
    await this.assertBusinessAccess(businessId, accountId);
    return this.repository.getGstr1(businessId, query);
  }

  async getGstr2(
    businessId: string,
    accountId: string,
    query: ReportBaseQuery,
  ) {
    await this.assertBusinessAccess(businessId, accountId);
    return this.repository.getGstr2(businessId, query);
  }

  async getGstr3b(
    businessId: string,
    accountId: string,
    query: ReportBaseQuery,
  ) {
    await this.assertBusinessAccess(businessId, accountId);
    return this.repository.getGstr3b(businessId, query);
  }

  getBillWiseProfit(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getBillWiseProfit(id, q),
    );
  }

  getCashFlow(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getCashFlow(id, q),
    );
  }

  getPartyWiseProfitLoss(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getPartyWiseProfitLoss(id, q),
    );
  }

  getPartyReportByItem(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getPartyReportByItem(id, q),
    );
  }

  getSalePurchaseByParty(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getSalePurchaseByParty(id, q),
    );
  }

  getSalePurchaseByPartyGroup(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getSalePurchaseByPartyGroup(id, q),
    );
  }

  async getGstr9(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    await this.assertBusinessAccess(businessId, accountId);
    return this.repository.getGstr9(businessId, query);
  }

  getSaleSummaryByHsn(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getSaleSummaryByHsn(id, q),
    );
  }

  getSacReport(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getSacReport(id, q),
    );
  }

  getItemReportByParty(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getItemReportByParty(id, q),
    );
  }

  getItemWiseProfitLoss(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getItemWiseProfitLoss(id, q),
    );
  }

  getStockDetail(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getStockDetail(id, q),
    );
  }

  getItemDetail(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getItemDetail(id, q),
    );
  }

  getSalePurchaseByItemCategory(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getSalePurchaseByItemCategory(id, q),
    );
  }

  getStockSummaryByItemCategory(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getStockSummaryByItemCategory(id, q),
    );
  }

  getItemCategoryWiseProfitLoss(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getItemCategoryWiseProfitLoss(id, q),
    );
  }

  getItemWiseDiscount(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getItemWiseDiscount(id, q),
    );
  }

  getManufacturing(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getManufacturing(id, q),
    );
  }

  getConsumption(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getConsumption(id, q),
    );
  }

  getStockTransfer(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getStockTransfer(id, q),
    );
  }

  async getBankStatement(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    await this.assertBusinessAccess(businessId, accountId);
    return this.repository.getBankStatement(businessId, query);
  }

  getGstReport(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getGstReport(id, q),
    );
  }

  getGstRateReport(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getGstRateReport(id, q),
    );
  }

  getForm27eq(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getForm27eq(id, q),
    );
  }

  getTcsReceivable(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getTcsReceivable(id, q),
    );
  }

  getTdsPayable(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getTdsPayable(id, q),
    );
  }

  getTdsReceivable(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getTdsReceivable(id, q),
    );
  }

  getExpenses(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getExpenses(id, q),
    );
  }

  getExpenseByCategory(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getExpenseByCategory(id, q),
    );
  }

  getExpenseByItem(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getExpenseByItem(id, q),
    );
  }

  getSalePurchaseOrders(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getSalePurchaseOrders(id, q),
    );
  }

  getSalePurchaseOrderItems(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getSalePurchaseOrderItems(id, q),
    );
  }

  getOtherIncome(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getOtherIncome(id, q),
    );
  }

  getOtherIncomeByCategory(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getOtherIncomeByCategory(id, q),
    );
  }

  getOtherIncomeByItem(
    businessId: string,
    accountId: string,
    query: ReportExtendedQuery,
  ) {
    return this.paginated(businessId, accountId, query, (id, q) =>
      this.repository.getOtherIncomeByItem(id, q),
    );
  }

  async getLoanStatement(
    businessId: string,
    accountId: string,
    query: LoanStatementQuery,
  ) {
    await this.assertBusinessAccess(businessId, accountId);
    return this.repository.getLoanStatement(businessId, query);
  }

  async getTrialBalance(
    businessId: string,
    accountId: string,
    query: ReportBaseQuery,
  ) {
    await this.assertBusinessAccess(businessId, accountId);
    return this.repository.getTrialBalance(businessId, query);
  }

  async getBalanceSheet(
    businessId: string,
    accountId: string,
    query: ReportBaseQuery,
  ) {
    await this.assertBusinessAccess(businessId, accountId);
    return this.repository.getBalanceSheet(businessId, query);
  }
}
