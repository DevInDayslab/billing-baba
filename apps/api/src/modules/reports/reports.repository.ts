import type { Database } from '../../db/client';
import type {
  LoanStatementQuery,
  PartyStatementQuery,
  ReportBaseQuery,
  ReportDateQuery,
  ReportExtendedQuery,
} from './reports.schema';
import { AccountingReportsRepository } from './repositories/accounting-reports.repository';
import { BusinessReportsRepository } from './repositories/business-reports.repository';
import { ExpenseReportsRepository } from './repositories/expense-reports.repository';
import { GstReportsRepository } from './repositories/gst-reports.repository';
import { ItemReportsRepository } from './repositories/item-reports.repository';
import { LoanReportsRepository } from './repositories/loan-reports.repository';
import { OrderReportsRepository } from './repositories/order-reports.repository';
import { OtherIncomeReportsRepository } from './repositories/other-income-reports.repository';
import { PartyReportsRepository } from './repositories/party-reports.repository';
import { Phase1ReportsRepository } from './repositories/phase1-reports.repository';
import { TaxReportsRepository } from './repositories/tax-reports.repository';
import { TransactionReportsRepository } from './repositories/transaction-reports.repository';

export class ReportsRepository {
  private readonly phase1: Phase1ReportsRepository;
  private readonly transaction: TransactionReportsRepository;
  private readonly party: PartyReportsRepository;
  private readonly gst: GstReportsRepository;
  private readonly item: ItemReportsRepository;
  private readonly business: BusinessReportsRepository;
  private readonly tax: TaxReportsRepository;
  private readonly expense: ExpenseReportsRepository;
  private readonly order: OrderReportsRepository;
  private readonly otherIncome: OtherIncomeReportsRepository;
  private readonly loan: LoanReportsRepository;
  private readonly accounting: AccountingReportsRepository;

  constructor(db: Database) {
    this.phase1 = new Phase1ReportsRepository(db);
    this.transaction = new TransactionReportsRepository(db);
    this.party = new PartyReportsRepository(db);
    this.gst = new GstReportsRepository(db);
    this.item = new ItemReportsRepository(db);
    this.business = new BusinessReportsRepository(db);
    this.tax = new TaxReportsRepository(db);
    this.expense = new ExpenseReportsRepository(db);
    this.order = new OrderReportsRepository(db);
    this.otherIncome = new OtherIncomeReportsRepository(db);
    this.loan = new LoanReportsRepository(db);
    this.accounting = new AccountingReportsRepository(db);
  }

  getSaleReport(businessId: string, query: ReportBaseQuery) {
    return this.phase1.getSaleReport(businessId, query);
  }

  getPurchaseReport(businessId: string, query: ReportBaseQuery) {
    return this.phase1.getPurchaseReport(businessId, query);
  }

  getStockSummary(businessId: string, query: ReportExtendedQuery) {
    return this.phase1.getStockSummary(businessId, query);
  }

  getLowStock(businessId: string, query: ReportExtendedQuery) {
    return this.phase1.getLowStock(businessId, query);
  }

  getPartyOutstanding(businessId: string, query: ReportExtendedQuery) {
    return this.phase1.getPartyOutstanding(businessId, query);
  }

  getPartyStatement(businessId: string, query: PartyStatementQuery) {
    return this.phase1.getPartyStatement(businessId, query);
  }

  getDayBook(businessId: string, query: ReportDateQuery) {
    return this.phase1.getDayBook(businessId, query);
  }

  getAllTransactions(businessId: string, query: ReportExtendedQuery) {
    return this.phase1.getAllTransactions(businessId, query);
  }

  getProfitLoss(businessId: string, query: ReportBaseQuery) {
    return this.phase1.getProfitLoss(businessId, query);
  }

  getGstr1(businessId: string, query: ReportBaseQuery) {
    return this.phase1.getGstr1(businessId, query);
  }

  getGstr2(businessId: string, query: ReportBaseQuery) {
    return this.phase1.getGstr2(businessId, query);
  }

  getGstr3b(businessId: string, query: ReportBaseQuery) {
    return this.phase1.getGstr3b(businessId, query);
  }

  getBillWiseProfit(businessId: string, query: ReportExtendedQuery) {
    return this.transaction.getBillWiseProfit(businessId, query);
  }

  getCashFlow(businessId: string, query: ReportExtendedQuery) {
    return this.transaction.getCashFlow(businessId, query);
  }

  getPartyWiseProfitLoss(businessId: string, query: ReportExtendedQuery) {
    return this.party.getPartyWiseProfitLoss(businessId, query);
  }

  getPartyReportByItem(businessId: string, query: ReportExtendedQuery) {
    return this.party.getPartyReportByItem(businessId, query);
  }

  getSalePurchaseByParty(businessId: string, query: ReportExtendedQuery) {
    return this.party.getSalePurchaseByParty(businessId, query);
  }

  getSalePurchaseByPartyGroup(businessId: string, query: ReportExtendedQuery) {
    return this.party.getSalePurchaseByPartyGroup(businessId, query);
  }

  getGstr9(businessId: string, query: ReportExtendedQuery) {
    return this.gst.getGstr9(businessId, query);
  }

  getSaleSummaryByHsn(businessId: string, query: ReportExtendedQuery) {
    return this.gst.getSaleSummaryByHsn(businessId, query);
  }

  getSacReport(businessId: string, query: ReportExtendedQuery) {
    return this.gst.getSacReport(businessId, query);
  }

  getItemReportByParty(businessId: string, query: ReportExtendedQuery) {
    return this.item.getItemReportByParty(businessId, query);
  }

  getItemWiseProfitLoss(businessId: string, query: ReportExtendedQuery) {
    return this.item.getItemWiseProfitLoss(businessId, query);
  }

  getStockDetail(businessId: string, query: ReportExtendedQuery) {
    return this.item.getStockDetail(businessId, query);
  }

  getItemDetail(businessId: string, query: ReportExtendedQuery) {
    return this.item.getItemDetail(businessId, query);
  }

  getSalePurchaseByItemCategory(businessId: string, query: ReportExtendedQuery) {
    return this.item.getSalePurchaseByItemCategory(businessId, query);
  }

  getStockSummaryByItemCategory(businessId: string, query: ReportExtendedQuery) {
    return this.item.getStockSummaryByItemCategory(businessId, query);
  }

  getItemCategoryWiseProfitLoss(businessId: string, query: ReportExtendedQuery) {
    return this.item.getItemCategoryWiseProfitLoss(businessId, query);
  }

  getItemWiseDiscount(businessId: string, query: ReportExtendedQuery) {
    return this.item.getItemWiseDiscount(businessId, query);
  }

  getManufacturing(businessId: string, query: ReportExtendedQuery) {
    return this.item.getManufacturing(businessId, query);
  }

  getConsumption(businessId: string, query: ReportExtendedQuery) {
    return this.item.getConsumption(businessId, query);
  }

  getStockTransfer(businessId: string, query: ReportExtendedQuery) {
    return this.item.getStockTransfer(businessId, query);
  }

  getBankStatement(businessId: string, query: ReportExtendedQuery) {
    return this.business.getBankStatement(businessId, query);
  }

  getGstReport(businessId: string, query: ReportExtendedQuery) {
    return this.tax.getGstReport(businessId, query);
  }

  getGstRateReport(businessId: string, query: ReportExtendedQuery) {
    return this.tax.getGstRateReport(businessId, query);
  }

  getForm27eq(businessId: string, query: ReportExtendedQuery) {
    return this.tax.getForm27eq(businessId, query);
  }

  getTcsReceivable(businessId: string, query: ReportExtendedQuery) {
    return this.tax.getTcsReceivable(businessId, query);
  }

  getTdsPayable(businessId: string, query: ReportExtendedQuery) {
    return this.tax.getTdsPayable(businessId, query);
  }

  getTdsReceivable(businessId: string, query: ReportExtendedQuery) {
    return this.tax.getTdsReceivable(businessId, query);
  }

  getExpenses(businessId: string, query: ReportExtendedQuery) {
    return this.expense.getExpenses(businessId, query);
  }

  getExpenseByCategory(businessId: string, query: ReportExtendedQuery) {
    return this.expense.getExpenseByCategory(businessId, query);
  }

  getExpenseByItem(businessId: string, query: ReportExtendedQuery) {
    return this.expense.getExpenseByItem(businessId, query);
  }

  getSalePurchaseOrders(businessId: string, query: ReportExtendedQuery) {
    return this.order.getSalePurchaseOrders(businessId, query);
  }

  getSalePurchaseOrderItems(businessId: string, query: ReportExtendedQuery) {
    return this.order.getSalePurchaseOrderItems(businessId, query);
  }

  getOtherIncome(businessId: string, query: ReportExtendedQuery) {
    return this.otherIncome.getOtherIncome(businessId, query);
  }

  getOtherIncomeByCategory(businessId: string, query: ReportExtendedQuery) {
    return this.otherIncome.getOtherIncomeByCategory(businessId, query);
  }

  getOtherIncomeByItem(businessId: string, query: ReportExtendedQuery) {
    return this.otherIncome.getOtherIncomeByItem(businessId, query);
  }

  getLoanStatement(businessId: string, query: LoanStatementQuery) {
    return this.loan.getLoanStatement(businessId, query);
  }

  getTrialBalance(businessId: string, query: ReportBaseQuery) {
    return this.accounting.getTrialBalance(businessId, query);
  }

  getBalanceSheet(businessId: string, query: ReportBaseQuery) {
    return this.accounting.getBalanceSheet(businessId, query);
  }
}
