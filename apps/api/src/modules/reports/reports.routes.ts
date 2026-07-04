import type { FastifyPluginAsync } from 'fastify';
import { authenticate } from '../../middleware/auth.middleware';
import { requireBusiness } from '../../middleware/require-business.middleware';
import { createReportsController } from './reports.controller';

export const createReportsRoutes = (): FastifyPluginAsync => {
  const controller = createReportsController();

  return async (app) => {
    const preHandler = [authenticate, requireBusiness];

    app.get('/sales', { preHandler }, controller.getSaleReport);
    app.get('/purchases', { preHandler }, controller.getPurchaseReport);
    app.get('/stock-summary', { preHandler }, controller.getStockSummary);
    app.get('/low-stock', { preHandler }, controller.getLowStock);
    app.get('/party-outstanding', { preHandler }, controller.getPartyOutstanding);
    app.get('/party-statement', { preHandler }, controller.getPartyStatement);
    app.get('/day-book', { preHandler }, controller.getDayBook);
    app.get('/all-transactions', { preHandler }, controller.getAllTransactions);
    app.get('/profit-loss', { preHandler }, controller.getProfitLoss);
    app.get('/gstr-1', { preHandler }, controller.getGstr1);
    app.get('/gstr-2', { preHandler }, controller.getGstr2);
    app.get('/gstr-3b', { preHandler }, controller.getGstr3b);

    app.get('/bill-wise-profit', { preHandler }, controller.getBillWiseProfit);
    app.get('/cash-flow', { preHandler }, controller.getCashFlow);

    app.get(
      '/party-wise-profit-loss',
      { preHandler },
      controller.getPartyWiseProfitLoss,
    );
    app.get(
      '/party-report-by-item',
      { preHandler },
      controller.getPartyReportByItem,
    );
    app.get(
      '/sale-purchase-by-party',
      { preHandler },
      controller.getSalePurchaseByParty,
    );
    app.get(
      '/sale-purchase-by-party-group',
      { preHandler },
      controller.getSalePurchaseByPartyGroup,
    );

    app.get('/gstr-9', { preHandler }, controller.getGstr9);
    app.get(
      '/sale-summary-by-hsn',
      { preHandler },
      controller.getSaleSummaryByHsn,
    );
    app.get('/sac-report', { preHandler }, controller.getSacReport);

    app.get(
      '/item-report-by-party',
      { preHandler },
      controller.getItemReportByParty,
    );
    app.get(
      '/item-wise-profit-loss',
      { preHandler },
      controller.getItemWiseProfitLoss,
    );
    app.get('/stock-detail', { preHandler }, controller.getStockDetail);
    app.get('/item-detail', { preHandler }, controller.getItemDetail);
    app.get(
      '/sale-purchase-by-item-category',
      { preHandler },
      controller.getSalePurchaseByItemCategory,
    );
    app.get(
      '/stock-summary-by-item-category',
      { preHandler },
      controller.getStockSummaryByItemCategory,
    );
    app.get(
      '/item-category-wise-profit-loss',
      { preHandler },
      controller.getItemCategoryWiseProfitLoss,
    );
    app.get(
      '/item-wise-discount',
      { preHandler },
      controller.getItemWiseDiscount,
    );
    app.get('/manufacturing', { preHandler }, controller.getManufacturing);
    app.get('/consumption', { preHandler }, controller.getConsumption);
    app.get('/stock-transfer', { preHandler }, controller.getStockTransfer);

    app.get('/bank-statement', { preHandler }, controller.getBankStatement);

    app.get('/gst-report', { preHandler }, controller.getGstReport);
    app.get('/gst-rate-report', { preHandler }, controller.getGstRateReport);
    app.get('/form-27eq', { preHandler }, controller.getForm27eq);
    app.get('/tcs-receivable', { preHandler }, controller.getTcsReceivable);
    app.get('/tds-payable', { preHandler }, controller.getTdsPayable);
    app.get('/tds-receivable', { preHandler }, controller.getTdsReceivable);

    app.get('/expenses', { preHandler }, controller.getExpenses);
    app.get(
      '/expense-by-category',
      { preHandler },
      controller.getExpenseByCategory,
    );
    app.get('/expense-by-item', { preHandler }, controller.getExpenseByItem);

    app.get(
      '/sale-purchase-orders',
      { preHandler },
      controller.getSalePurchaseOrders,
    );
    app.get(
      '/sale-purchase-order-items',
      { preHandler },
      controller.getSalePurchaseOrderItems,
    );

    app.get('/other-income', { preHandler }, controller.getOtherIncome);
    app.get(
      '/other-income-by-category',
      { preHandler },
      controller.getOtherIncomeByCategory,
    );
    app.get(
      '/other-income-by-item',
      { preHandler },
      controller.getOtherIncomeByItem,
    );

    app.get('/loan-statement', { preHandler }, controller.getLoanStatement);
    app.get('/trial-balance', { preHandler }, controller.getTrialBalance);
    app.get('/balance-sheet', { preHandler }, controller.getBalanceSheet);
  };
};
