import type { Database } from '../../../db/client';
import {
  calculateNetProfit,
  getCashBalanceAsOf,
  getCashMovement,
  getOutstandingAsOf,
  getStockValue,
  getLoansOutstandingAsOf,
  sumExpensesAmount,
  sumLoanFinancingExpense,
  sumOtherIncomeAmount,
  sumPartyOpeningBalances,
  sumPurchasesAmount,
  sumSalesAmount,
} from '../../../shared/reporting/accounting-summary';
import {
  PURCHASE_BILL_TYPE,
  PURCHASE_RETURN_TYPE,
  REVENUE_SALES_TYPES,
  SALES_RETURN_TYPE,
} from '../../../shared/reporting/constants';
import type { ReportBaseQuery } from '../reports.schema';
import type {
  BalanceSheetPayload,
  ProfitLossPayload,
  ReportBalanceSheetItem,
  ReportProfitLossItem,
  ReportTrialBalanceRow,
  TrialBalancePayload,
} from '../reports.types';
import { resolveRange, toPeriodMeta } from './reports.helpers';

function money(value: number): string {
  return value.toFixed(2);
}

function trialRow(
  accountName: string,
  opening: number,
  debit: number,
  credit: number,
): ReportTrialBalanceRow {
  const closing = opening + debit - credit;
  return {
    account_name: accountName,
    opening: money(opening),
    debit: money(debit),
    credit: money(credit),
    closing: money(Math.abs(closing)),
    balance_type: closing >= 0 ? 'debit' : 'credit',
  };
}

function closingTotals(rows: ReportTrialBalanceRow[]): {
  debit: number;
  credit: number;
} {
  return rows.reduce(
    (totals, row) => {
      if (row.balance_type === 'debit') {
        totals.debit += Number(row.closing);
      } else {
        totals.credit += Number(row.closing);
      }
      return totals;
    },
    { debit: 0, credit: 0 },
  );
}

export class AccountingReportsRepository {
  constructor(private readonly db: Database) {}

  async getTrialBalance(
    businessId: string,
    query: ReportBaseQuery,
  ): Promise<TrialBalancePayload> {
    const range = resolveRange(query);
    const openingAsOf = new Date(range.from.getTime() - 1);
    const closingAsOf = new Date(range.to.getTime() - 1);

    const [
      openingOutstanding,
      closingOutstanding,
      openingCash,
      closingCash,
      cashMovement,
      salesTotal,
      salesReturnTotal,
      purchaseTotal,
      purchaseReturnTotal,
      expenseTotal,
      stockValue,
      partyOpening,
    ] = await Promise.all([
      getOutstandingAsOf(this.db, businessId, openingAsOf),
      getOutstandingAsOf(this.db, businessId, closingAsOf),
      getCashBalanceAsOf(this.db, businessId, openingAsOf),
      getCashBalanceAsOf(this.db, businessId, closingAsOf),
      getCashMovement(this.db, businessId, range),
      sumSalesAmount(this.db, businessId, range, REVENUE_SALES_TYPES),
      sumSalesAmount(this.db, businessId, range, [SALES_RETURN_TYPE]),
      sumPurchasesAmount(this.db, businessId, range, PURCHASE_BILL_TYPE),
      sumPurchasesAmount(this.db, businessId, range, PURCHASE_RETURN_TYPE),
      sumExpensesAmount(this.db, businessId, range),
      getStockValue(this.db, businessId),
      sumPartyOpeningBalances(this.db, businessId),
    ]);

    const receivableOpening = openingOutstanding.receivable;
    const receivableClosing = closingOutstanding.receivable;
    const receivableDebit = Math.max(0, receivableClosing - receivableOpening);
    const receivableCredit = Math.max(0, receivableOpening - receivableClosing);

    const payableOpening = openingOutstanding.payable;
    const payableClosing = closingOutstanding.payable;
    const payableDebit = Math.max(0, payableOpening - payableClosing);
    const payableCredit = Math.max(0, payableClosing - payableOpening);

    const netProfit = await calculateNetProfit(this.db, businessId, range);

    const stockOpening = Math.max(
      0,
      stockValue - (purchaseTotal - purchaseReturnTotal),
    );
    const openingEquity =
      openingCash + receivableOpening + stockValue - payableOpening;
    const openingRetained = openingEquity - partyOpening;
    const closingEquity =
      closingCash + receivableClosing + stockValue - payableClosing;
    const closingRetained = closingEquity - partyOpening - netProfit;
    const retainedMovement = closingRetained - openingRetained;

    const rows: ReportTrialBalanceRow[] = [
      trialRow(
        'Cash & Bank',
        openingCash,
        cashMovement.received,
        cashMovement.paid,
      ),
      trialRow(
        'Sundry Debtors',
        receivableOpening,
        receivableDebit,
        receivableCredit,
      ),
      trialRow(
        'Stock in Hand',
        stockOpening,
        purchaseTotal,
        purchaseReturnTotal,
      ),
      trialRow(
        'Sundry Creditors',
        -payableOpening,
        payableDebit,
        payableCredit,
      ),
      trialRow('Capital Account', partyOpening, 0, 0),
      trialRow(
        'Retained Earnings / Opening Balance',
        openingRetained,
        retainedMovement > 0 ? retainedMovement : 0,
        retainedMovement < 0 ? Math.abs(retainedMovement) : 0,
      ),
      trialRow('Sales', 0, salesReturnTotal, salesTotal),
      trialRow('Purchases', 0, purchaseTotal, purchaseReturnTotal),
      trialRow('Expenses', 0, expenseTotal, 0),
      trialRow(
        'Net Profit',
        0,
        netProfit < 0 ? Math.abs(netProfit) : 0,
        netProfit > 0 ? netProfit : 0,
      ),
    ].filter((row) => {
      if (query.q) {
        return row.account_name
          .toLowerCase()
          .includes(query.q?.toLowerCase() ?? '');
      }
      return true;
    });

    let { debit: totalDebit, credit: totalCredit } = closingTotals(rows);
    const difference = totalDebit - totalCredit;
    if (Math.abs(difference) > 0.01) {
      rows.push(
        trialRow(
          'Rounding Difference',
          0,
          difference < 0 ? Math.abs(difference) : 0,
          difference > 0 ? difference : 0,
        ),
      );
      ({ debit: totalDebit, credit: totalCredit } = closingTotals(rows));
    }

    return {
      period: toPeriodMeta(range),
      rows,
      total_debit: money(totalDebit),
      total_credit: money(totalCredit),
      is_balanced: Math.abs(totalDebit - totalCredit) < 0.02,
    };
  }

  async getBalanceSheet(
    businessId: string,
    query: ReportBaseQuery,
  ): Promise<BalanceSheetPayload> {
    const range = resolveRange(query);
    const asOn = new Date(range.to.getTime() - 1);

    const [
      outstanding,
      cash,
      stockValue,
      netProfit,
      partyOpening,
      openingOutstanding,
      openingCash,
      openingStock,
      loansOutstanding,
    ] = await Promise.all([
      getOutstandingAsOf(this.db, businessId, asOn),
      getCashBalanceAsOf(this.db, businessId, asOn),
      getStockValue(this.db, businessId),
      calculateNetProfit(this.db, businessId, range),
      sumPartyOpeningBalances(this.db, businessId),
      getOutstandingAsOf(
        this.db,
        businessId,
        new Date(range.from.getTime() - 1),
      ),
      getCashBalanceAsOf(
        this.db,
        businessId,
        new Date(range.from.getTime() - 1),
      ),
      getStockValue(this.db, businessId),
      getLoansOutstandingAsOf(this.db, businessId, asOn),
    ]);

    const assetsTotal = cash + outstanding.receivable + stockValue;
    const liabilitiesTotal = outstanding.payable + loansOutstanding;
    const equityBeforePlug = assetsTotal - liabilitiesTotal;
    const retainedEarnings = equityBeforePlug - partyOpening - netProfit;

    const assets: ReportBalanceSheetItem[] = [
      { name: 'Current Assets', amount: '0', indent: 0, is_header: true },
      { name: 'Cash & Bank', amount: money(cash), indent: 1, is_header: false },
      {
        name: 'Sundry Debtors',
        amount: money(outstanding.receivable),
        indent: 1,
        is_header: false,
      },
      {
        name: 'Stock in Hand',
        amount: money(stockValue),
        indent: 1,
        is_header: false,
      },
    ];

    const liabilities: ReportBalanceSheetItem[] = [
      {
        name: 'Current Liabilities',
        amount: '0',
        indent: 0,
        is_header: true,
      },
      {
        name: 'Sundry Creditors',
        amount: money(outstanding.payable),
        indent: 1,
        is_header: false,
      },
      {
        name: 'Loans',
        amount: money(loansOutstanding),
        indent: 1,
        is_header: false,
      },
      {
        name: 'Capital & Reserves',
        amount: '0',
        indent: 0,
        is_header: true,
      },
      {
        name: 'Capital Account',
        amount: money(Math.max(0, partyOpening)),
        indent: 1,
        is_header: false,
      },
      {
        name: 'Retained Earnings',
        amount: money(retainedEarnings),
        indent: 1,
        is_header: false,
      },
      {
        name: 'Net Profit (Period)',
        amount: money(netProfit),
        indent: 1,
        is_header: false,
      },
    ];

    const liabilitiesAndEquityTotal = liabilitiesTotal + equityBeforePlug;
    const openingAssets =
      openingCash + openingOutstanding.receivable + openingStock;
    const openingLiabilities = openingOutstanding.payable;
    const openingEquity = openingAssets - openingLiabilities;
    const closingEquity = equityBeforePlug;

    return {
      period: toPeriodMeta(range),
      as_on: asOn.toISOString(),
      assets,
      liabilities,
      assets_total: money(assetsTotal),
      liabilities_total: money(liabilitiesAndEquityTotal),
      net_profit: money(netProfit),
      opening_assets: money(openingAssets),
      closing_assets: money(assetsTotal),
      opening_liabilities: money(openingLiabilities),
      closing_liabilities: money(liabilitiesAndEquityTotal),
      opening_equity: money(openingEquity),
      closing_equity: money(closingEquity),
      is_balanced: Math.abs(assetsTotal - liabilitiesAndEquityTotal) < 0.02,
    };
  }

  async getProfitLoss(
    businessId: string,
    query: ReportBaseQuery,
  ): Promise<ProfitLossPayload> {
    const range = resolveRange(query);

    const [
      salesTotal,
      salesReturnTotal,
      purchaseTotal,
      purchaseReturnTotal,
      expenseTotal,
      stockValue,
      netProfit,
      otherDirectTotal,
      otherIndirectTotal,
      loanFinancing,
    ] = await Promise.all([
      sumSalesAmount(this.db, businessId, range, REVENUE_SALES_TYPES),
      sumSalesAmount(this.db, businessId, range, [SALES_RETURN_TYPE]),
      sumPurchasesAmount(this.db, businessId, range, PURCHASE_BILL_TYPE),
      sumPurchasesAmount(this.db, businessId, range, PURCHASE_RETURN_TYPE),
      sumExpensesAmount(this.db, businessId, range),
      getStockValue(this.db, businessId),
      calculateNetProfit(this.db, businessId, range),
      sumOtherIncomeAmount(this.db, businessId, range, 'direct'),
      sumOtherIncomeAmount(this.db, businessId, range, 'indirect'),
      sumLoanFinancingExpense(this.db, businessId, range),
    ]);

    const netSales = salesTotal - salesReturnTotal;
    const netPurchases = purchaseTotal - purchaseReturnTotal;
    const openingStock = Math.max(0, stockValue - netPurchases);
    const closingStock = stockValue;

    const saleAccountsTotal = netSales;
    const totalIncomes =
      saleAccountsTotal + otherDirectTotal + otherIndirectTotal;

    const costOfGoodsSold = openingStock + netPurchases - closingStock;
    const directExpenses = 0;
    const indirectExpenses = expenseTotal;
    const totalExpenses = costOfGoodsSold + directExpenses + indirectExpenses;

    const row = (
      particular: string,
      amount: number,
      isHeader: boolean,
      indent: number,
    ): ReportProfitLossItem => ({
      particular,
      amount: money(amount),
      is_header: isHeader,
      indent,
    });

    const items: ReportProfitLossItem[] = [
      row('Incomes', totalIncomes, true, 0),
      row('Sale Accounts', saleAccountsTotal, true, 1),
      row('Sale (Revenue) Account', netSales, false, 2),
      row('Additional Charges on Sale', 0, false, 2),
      row('Other Incomes (Direct)', otherDirectTotal, true, 1),
      row('Payment-out Discount', 0, false, 2),
      row('Other Direct Incomes', otherDirectTotal, false, 2),
      row('Other Incomes (Indirect)', otherIndirectTotal, true, 1),
      row('Interest Received', 0, false, 2),
      row('Other Indirect Incomes', otherIndirectTotal, false, 2),
      row('Expenses', totalExpenses, true, 0),
      row('Cost of Goods Sold', costOfGoodsSold, true, 1),
      row('Purchase Accounts', netPurchases, false, 2),
      row('Opening Stock', openingStock, false, 2),
      row('Closing Stock', closingStock, false, 2),
      row('Direct Expenses', directExpenses, true, 1),
      row('Indirect Expenses', indirectExpenses, true, 1),
      row('Cost of Financing', loanFinancing, false, 2),
      row('Other Expenses', expenseTotal, false, 2),
      row('Net Profit (Incomes - Expenses)', netProfit, true, 0),
    ];

    return {
      period: toPeriodMeta(range),
      net_profit: money(netProfit),
      items,
    };
  }
}
