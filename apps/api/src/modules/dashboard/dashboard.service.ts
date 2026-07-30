import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { BusinessMembershipRepository } from '../../shared/repositories/business-membership.repository';
import { toDashboardResponse } from './dashboard.mapper';
import { DashboardRepository } from './dashboard.repository';
import type { DashboardQuery } from './dashboard.schema';
import type { DashboardPayload, DashboardQuickReport } from './dashboard.types';
import { resolveDashboardPeriod } from './dashboard-period';

const QUICK_REPORTS: DashboardQuickReport[] = [
  { key: 'sale_report', title: 'Sale Report', route: '/reports' },
  { key: 'all_transactions', title: 'All Transactions', route: '/reports' },
  { key: 'daybook', title: 'Daybook Report', route: '/reports' },
  { key: 'party_statement', title: 'Party Statement', route: '/reports' },
];

export class DashboardService {
  private readonly repository: DashboardRepository;
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
    this.repository = new DashboardRepository(db);
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

  async getDashboard(
    businessId: string,
    accountId: string,
    query: DashboardQuery,
  ): Promise<DashboardPayload> {
    await this.assertBusinessAccess(businessId, accountId);

    const range = resolveDashboardPeriod({
      period: query.period,
      from: query.from,
      to: query.to,
    });

    const [
      overview,
      sales,
      purchases,
      finance,
      inventory,
      salesTrend,
      purchasesTrend,
      recentTransactions,
    ] = await Promise.all([
      this.repository.getOverview(businessId),
      this.repository.getSalesSummary(businessId, range),
      this.repository.getPurchaseSummary(businessId, range),
      this.repository.getTodayFinanceSummary(businessId),
      this.repository.getInventorySummary(businessId),
      this.repository.getSalesTrend(businessId, range),
      this.repository.getPurchasesTrend(businessId, range),
      this.repository.getRecentTransactions(businessId),
    ]);

    const payload: DashboardPayload = {
      generated_at: new Date().toISOString(),
      period: {
        period: range.key,
        from: range.from.toISOString(),
        to: range.to.toISOString(),
      },
      overview,
      sales,
      purchases,
      finance,
      inventory,
      charts: {
        sales_trend: salesTrend,
        purchases_trend: purchasesTrend,
      },
      alerts: [],
      recent_transactions: recentTransactions,
      top_parties: {
        top_customer: null,
        top_supplier: null,
      },
      quick_reports: QUICK_REPORTS,
    };

    return toDashboardResponse(payload);
  }
}
