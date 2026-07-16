import type { Database } from '../../../db/client';
import type { ReportExtendedQuery } from '../reports.schema';
import type {
  PaginatedRowsPayload,
  ReportOtherIncomeCategoryRow,
  ReportOtherIncomeItemRow,
  ReportOtherIncomeRow,
} from '../reports.types';
import { resolveRange, toPeriodMeta } from './reports.helpers';

export class OtherIncomeReportsRepository {
  constructor(readonly _db: Database) {}

  private emptyPaginated<T>(query: ReportExtendedQuery): {
    payload: PaginatedRowsPayload<T>;
    total: number;
  } {
    return {
      total: 0,
      payload: {
        period: toPeriodMeta(resolveRange(query)),
        rows: [],
      },
    };
  }

  async getOtherIncome(
    _businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{
    payload: PaginatedRowsPayload<ReportOtherIncomeRow>;
    total: number;
  }> {
    return this.emptyPaginated(query);
  }

  async getOtherIncomeByCategory(
    _businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{
    payload: PaginatedRowsPayload<ReportOtherIncomeCategoryRow>;
    total: number;
  }> {
    return this.emptyPaginated(query);
  }

  async getOtherIncomeByItem(
    _businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{
    payload: PaginatedRowsPayload<ReportOtherIncomeItemRow>;
    total: number;
  }> {
    return this.emptyPaginated(query);
  }
}
