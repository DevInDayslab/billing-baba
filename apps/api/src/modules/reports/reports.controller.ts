import type { FastifyReply, FastifyRequest } from 'fastify';
import {
  handleDataReport,
  handlePaginatedReport,
} from './reports.controller-helpers';
import {
  loanStatementQuerySchema,
  partyStatementQuerySchema,
  reportBaseQuerySchema,
  reportDateQuerySchema,
  reportExtendedQuerySchema,
} from './reports.schema';
import { ReportsService } from './reports.service';

export function createReportsController() {
  const service = new ReportsService();

  return {
    getSaleReport: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportBaseQuerySchema,
        service.getSaleReport.bind(service),
        'sales-report.csv',
      ),

    getPurchaseReport: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportBaseQuerySchema,
        service.getPurchaseReport.bind(service),
        'purchases-report.csv',
      ),

    getStockSummary: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportBaseQuerySchema,
        service.getStockSummary.bind(service),
        'stock-summary.csv',
      ),

    getLowStock: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportBaseQuerySchema,
        service.getLowStock.bind(service),
        'low-stock.csv',
      ),

    getPartyOutstanding: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportBaseQuerySchema,
        service.getPartyOutstanding.bind(service),
        'party-outstanding.csv',
      ),

    getPartyStatement: (request: FastifyRequest, reply: FastifyReply) =>
      handleDataReport(
        request,
        reply,
        partyStatementQuerySchema,
        service.getPartyStatement.bind(service),
      ),

    getDayBook: (request: FastifyRequest, reply: FastifyReply) =>
      handleDataReport(
        request,
        reply,
        reportDateQuerySchema,
        service.getDayBook.bind(service),
      ),

    getAllTransactions: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportBaseQuerySchema,
        service.getAllTransactions.bind(service),
        'all-transactions.csv',
      ),

    getProfitLoss: (request: FastifyRequest, reply: FastifyReply) =>
      handleDataReport(
        request,
        reply,
        reportBaseQuerySchema,
        service.getProfitLoss.bind(service),
      ),

    getGstr1: (request: FastifyRequest, reply: FastifyReply) =>
      handleDataReport(
        request,
        reply,
        reportBaseQuerySchema,
        service.getGstr1.bind(service),
      ),

    getGstr2: (request: FastifyRequest, reply: FastifyReply) =>
      handleDataReport(
        request,
        reply,
        reportBaseQuerySchema,
        service.getGstr2.bind(service),
      ),

    getGstr3b: (request: FastifyRequest, reply: FastifyReply) =>
      handleDataReport(
        request,
        reply,
        reportBaseQuerySchema,
        service.getGstr3b.bind(service),
      ),

    getBillWiseProfit: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getBillWiseProfit.bind(service),
        'bill-wise-profit.csv',
      ),

    getCashFlow: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getCashFlow.bind(service),
        'cash-flow.csv',
      ),

    getPartyWiseProfitLoss: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getPartyWiseProfitLoss.bind(service),
        'party-wise-profit-loss.csv',
      ),

    getPartyReportByItem: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getPartyReportByItem.bind(service),
        'party-report-by-item.csv',
      ),

    getSalePurchaseByParty: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getSalePurchaseByParty.bind(service),
        'sale-purchase-by-party.csv',
      ),

    getSalePurchaseByPartyGroup: (
      request: FastifyRequest,
      reply: FastifyReply,
    ) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getSalePurchaseByPartyGroup.bind(service),
        'sale-purchase-by-party-group.csv',
      ),

    getGstr9: (request: FastifyRequest, reply: FastifyReply) =>
      handleDataReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getGstr9.bind(service),
      ),

    getSaleSummaryByHsn: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getSaleSummaryByHsn.bind(service),
        'sale-summary-by-hsn.csv',
      ),

    getSacReport: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getSacReport.bind(service),
        'sac-report.csv',
      ),

    getItemReportByParty: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getItemReportByParty.bind(service),
        'item-report-by-party.csv',
      ),

    getItemWiseProfitLoss: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getItemWiseProfitLoss.bind(service),
        'item-wise-profit-loss.csv',
      ),

    getStockDetail: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getStockDetail.bind(service),
        'stock-detail.csv',
      ),

    getItemDetail: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getItemDetail.bind(service),
        'item-detail.csv',
      ),

    getSalePurchaseByItemCategory: (
      request: FastifyRequest,
      reply: FastifyReply,
    ) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getSalePurchaseByItemCategory.bind(service),
        'sale-purchase-by-item-category.csv',
      ),

    getStockSummaryByItemCategory: (
      request: FastifyRequest,
      reply: FastifyReply,
    ) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getStockSummaryByItemCategory.bind(service),
        'stock-summary-by-item-category.csv',
      ),

    getItemCategoryWiseProfitLoss: (
      request: FastifyRequest,
      reply: FastifyReply,
    ) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getItemCategoryWiseProfitLoss.bind(service),
        'item-category-wise-profit-loss.csv',
      ),

    getItemWiseDiscount: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getItemWiseDiscount.bind(service),
        'item-wise-discount.csv',
      ),

    getManufacturing: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getManufacturing.bind(service),
        'manufacturing.csv',
      ),

    getConsumption: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getConsumption.bind(service),
        'consumption.csv',
      ),

    getStockTransfer: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getStockTransfer.bind(service),
        'stock-transfer.csv',
      ),

    getBankStatement: (request: FastifyRequest, reply: FastifyReply) =>
      handleDataReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getBankStatement.bind(service),
      ),

    getGstReport: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getGstReport.bind(service),
        'gst-report.csv',
      ),

    getGstRateReport: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getGstRateReport.bind(service),
        'gst-rate-report.csv',
      ),

    getForm27eq: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getForm27eq.bind(service),
        'form-27eq.csv',
      ),

    getTcsReceivable: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getTcsReceivable.bind(service),
        'tcs-receivable.csv',
      ),

    getTdsPayable: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getTdsPayable.bind(service),
        'tds-payable.csv',
      ),

    getTdsReceivable: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getTdsReceivable.bind(service),
        'tds-receivable.csv',
      ),

    getExpenses: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getExpenses.bind(service),
        'expenses.csv',
      ),

    getExpenseByCategory: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getExpenseByCategory.bind(service),
        'expense-by-category.csv',
      ),

    getExpenseByItem: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getExpenseByItem.bind(service),
        'expense-by-item.csv',
      ),

    getSalePurchaseOrders: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getSalePurchaseOrders.bind(service),
        'sale-purchase-orders.csv',
      ),

    getSalePurchaseOrderItems: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getSalePurchaseOrderItems.bind(service),
        'sale-purchase-order-items.csv',
      ),

    getOtherIncome: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getOtherIncome.bind(service),
        'other-income.csv',
      ),

    getOtherIncomeByCategory: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getOtherIncomeByCategory.bind(service),
        'other-income-by-category.csv',
      ),

    getOtherIncomeByItem: (request: FastifyRequest, reply: FastifyReply) =>
      handlePaginatedReport(
        request,
        reply,
        reportExtendedQuerySchema,
        service.getOtherIncomeByItem.bind(service),
        'other-income-by-item.csv',
      ),

    getLoanStatement: (request: FastifyRequest, reply: FastifyReply) =>
      handleDataReport(
        request,
        reply,
        loanStatementQuerySchema,
        service.getLoanStatement.bind(service),
      ),

    getTrialBalance: (request: FastifyRequest, reply: FastifyReply) =>
      handleDataReport(
        request,
        reply,
        reportBaseQuerySchema,
        service.getTrialBalance.bind(service),
      ),

    getBalanceSheet: (request: FastifyRequest, reply: FastifyReply) =>
      handleDataReport(
        request,
        reply,
        reportBaseQuerySchema,
        service.getBalanceSheet.bind(service),
      ),
  };
}
