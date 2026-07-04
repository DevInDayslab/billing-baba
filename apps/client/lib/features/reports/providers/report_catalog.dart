import 'package:billing_baba/features/inventory/providers/inventory_catalog.dart';
import 'package:billing_baba/features/parties/providers/party_catalog.dart';
import 'package:billing_baba/features/parties/providers/party_groups_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';

/// Seed catalog for report UI until Drift repositories are wired.
/// Uses party, inventory, and invoice naming from existing catalogs.
abstract final class ReportCatalog {
  static const _gstins = [
    '27AABCS1429B1Z5',
    '24AAACP2672E1Z3',
    '09AAACG3773F1Z8',
    '07AAACB2894G1Z1',
    '29AABCU9603R1ZM',
    '33AAACB1534F1Z2',
    '06AAACB2894G1Z4',
    '19AAACB1534F1Z6',
    '23AAACB2894G1Z7',
    '32AAACB1534F1Z9',
    '36AAACB2894G1Z0',
    '18AAACB1534F1Z3',
  ];

  static const _hsnCodes = [
  ('1006', 'Rice 25kg', 'BAG'),
  ('1101', 'Wheat Flour 10kg', 'BAG'),
  ('3305', 'Hair Oil 200ml', 'PCS'),
  ('3004', 'Paracetamol 500mg', 'STR'),
  ('8471', 'Laptop Accessories', 'PCS'),
  ('5208', 'Cotton Fabric', 'MTR'),
  ('2202', 'Soft Drink 750ml', 'BTL'),
  ('2710', 'Thinner 500ml', 'LTR'),
  ];

  static const _expenseItems = [
    ('Shop Rent', 'Rent'),
    ('Electricity Bill', 'Utilities'),
    ('Staff Salary', 'Salaries'),
    ('Delivery Charges', 'Transport'),
    ('Facebook Ads', 'Marketing'),
    ('Printer Paper', 'Office Supplies'),
    ('Water Bill', 'Utilities'),
    ('Vehicle Fuel', 'Transport'),
  ];

  static const _otherIncomeItems = [
    ('Bank Interest', 'Interest Income'),
    ('Property Rent', 'Rental Income'),
    ('Referral Commission', 'Commission Income'),
    ('Scrap Sale', 'Miscellaneous'),
    ('Service Charges', 'Service Income'),
    ('Late Fee Received', 'Miscellaneous'),
    ('Insurance Claim', 'Miscellaneous'),
    ('Dividend Income', 'Investment Income'),
  ];

  static const _banks = ['HDFC Bank', 'ICICI Bank', 'SBI'];

  static const _loanAccounts = [
    'Business Term Loan',
    'Working Capital Loan',
    'Vehicle Loan',
  ];

  static const _godowns = ['Main Godown', 'Godown 2'];

  static const _sacCodes = ['998311', '998313', '998314'];

  static const _taxRates = [5.0, 12.0, 18.0, 28.0];

  // ── Transaction reports ──────────────────────────────────────────────

  static List<ReportTransactionRow> allTransactions() {
    final rows = <ReportTransactionRow>[];
    var id = 1;

    for (var i = 0; i < PartyCatalog.parties.length; i++) {
      final party = PartyCatalog.parties[i];
      final month = 3 + (i % 5);
      final day = (i % 28) + 1;
      final amount = 2500 + ((id * 830) % 22000).toDouble();
      final status = SaleInvoiceStatus.values[i % 5];
      final balance = switch (status) {
        SaleInvoiceStatus.paid => 0.0,
        SaleInvoiceStatus.cancelled => 0.0,
        SaleInvoiceStatus.unpaid => amount,
        SaleInvoiceStatus.overdue => amount,
        SaleInvoiceStatus.partiallyPaid => (amount * 0.45),
      };
      final received = amount - balance;

      rows.add(
        ReportTransactionRow(
          id: 'txn-$id',
          date: DateTime(2026, month, day),
          refNo: 'SI-${1000 + id}',
          partyName: party.name,
          category: 'Sales',
          type: 'Sale',
          total: amount,
          received: received,
          balance: balance,
          moneyIn: received,
          dueDate: DateTime(2026, month, day + 15),
          status: _statusLabel(status),
          paymentType: ['Cash', 'Credit', 'UPI', 'Cheque'][id % 4],
        ),
      );
      id++;

      if (i.isEven) {
        final purchaseAmount = 1800 + ((id * 620) % 15000).toDouble();
        rows.add(
          ReportTransactionRow(
            id: 'txn-$id',
            date: DateTime(2026, month, day + 2),
            refNo: 'PI-${2000 + id}',
            partyName: party.name,
            category: 'Purchase',
            type: 'Purchase',
            total: purchaseAmount,
            moneyOut: purchaseAmount,
            status: 'Paid',
            paymentType: 'Credit',
          ),
        );
        id++;
      }

      if (i % 3 == 0) {
        final paymentAmount = 1500 + ((id * 400) % 8000).toDouble();
        rows.add(
          ReportTransactionRow(
            id: 'txn-$id',
            date: DateTime(2026, month, day + 5),
            refNo: 'PIN-${3000 + id}',
            partyName: party.name,
            category: 'Payment',
            type: 'Payment In',
            total: paymentAmount,
            received: paymentAmount,
            moneyIn: paymentAmount,
            status: 'Paid',
            paymentType: 'UPI',
          ),
        );
        id++;
      }
    }

    rows.sort((a, b) => b.date.compareTo(a.date));
    return rows;
  }

  static List<ReportTransactionRow> dayBookForDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return allTransactions().where((row) {
      final rowDate = DateTime(row.date.year, row.date.month, row.date.day);
      return rowDate == normalized;
    }).toList();
  }

  static List<ReportPurchaseRow> purchases() {
    return List.generate(18, (index) {
      final party = PartyCatalog.parties[index % PartyCatalog.parties.length];
      final month = 3 + (index % 5);
      final day = (index % 28) + 1;
      final amount = 1800 + ((index + 1) * 620) % 15000;
      final status = SaleInvoiceStatus.values[index % 4];
      final balance = switch (status) {
        SaleInvoiceStatus.paid => 0.0,
        SaleInvoiceStatus.cancelled => 0.0,
        SaleInvoiceStatus.unpaid => amount.toDouble(),
        SaleInvoiceStatus.overdue => amount.toDouble(),
        SaleInvoiceStatus.partiallyPaid => (amount * 0.5),
      };

      return ReportPurchaseRow(
        id: 'pur-${index + 1}',
        date: DateTime(2026, month, day),
        invoiceNo: 'PI-${2000 + index + 1}',
        partyName: party.name,
        paymentType: ['Cash', 'Credit', 'UPI'][index % 3],
        status: status,
        amount: amount.toDouble(),
        balance: balance,
      );
    });
  }

  static double purchaseTotalAmount() =>
      purchases().fold(0.0, (sum, r) => sum + r.amount);

  static double purchasePaidAmount() =>
      purchases().fold(0.0, (sum, r) => sum + (r.amount - r.balance));

  static double purchaseBalanceAmount() =>
      purchases().fold(0.0, (sum, r) => sum + r.balance);

  static List<ReportProfitLossItem> profitLossItems() => const [
    ReportProfitLossItem(particular: 'Sales', amount: 0, isHeader: true),
    ReportProfitLossItem(particular: 'Sale', amount: 485200, indent: 1),
    ReportProfitLossItem(particular: 'Sale Return', amount: -12400, indent: 1),
    ReportProfitLossItem(particular: 'Purchases', amount: 0, isHeader: true),
    ReportProfitLossItem(particular: 'Purchase', amount: -312800, indent: 1),
    ReportProfitLossItem(particular: 'Purchase Return', amount: 8600, indent: 1),
    ReportProfitLossItem(particular: 'Direct Expenses', amount: 0, isHeader: true),
    ReportProfitLossItem(particular: 'Transport', amount: -18500, indent: 1),
    ReportProfitLossItem(particular: 'Salaries', amount: -72000, indent: 1),
    ReportProfitLossItem(particular: 'Gross Profit', amount: 78100, isHeader: true),
    ReportProfitLossItem(particular: 'Indirect Expenses', amount: 0, isHeader: true),
    ReportProfitLossItem(particular: 'Rent', amount: -36000, indent: 1),
    ReportProfitLossItem(particular: 'Utilities', amount: -8400, indent: 1),
    ReportProfitLossItem(particular: 'Marketing', amount: -15200, indent: 1),
    ReportProfitLossItem(particular: 'Net Profit', amount: 18500, isHeader: true),
  ];

  static double profitLossNetProfit() => 18500;

  static List<ReportBillWiseProfitRow> billWiseProfit() {
    return List.generate(12, (index) {
      final party = PartyCatalog.parties[index];
      final saleAmount = 3500 + ((index + 1) * 920) % 18000;
      final purchaseAmount = 2200 + ((index + 1) * 540) % 12000;
      return ReportBillWiseProfitRow(
        date: DateTime(2026, 4 + (index % 3), (index % 28) + 1),
        invoiceNo: 'SI-${1001 + index}',
        partyName: party.name,
        saleAmount: saleAmount.toDouble(),
        purchaseAmount: purchaseAmount.toDouble(),
        profit: (saleAmount - purchaseAmount).toDouble(),
      );
    });
  }

  static double billWiseProfitTotal() =>
      billWiseProfit().fold(0.0, (sum, r) => sum + r.profit);

  static List<ReportTrialBalanceRow> trialBalance() => const [
    ReportTrialBalanceRow(accountName: 'Cash in Hand', debit: 45200, credit: 0),
    ReportTrialBalanceRow(accountName: 'Bank - HDFC', debit: 128500, credit: 0),
    ReportTrialBalanceRow(accountName: 'Sundry Debtors', debit: 76550, credit: 0),
    ReportTrialBalanceRow(accountName: 'Stock in Hand', debit: 89400, credit: 0),
    ReportTrialBalanceRow(accountName: 'Sundry Creditors', debit: 0, credit: 46900),
    ReportTrialBalanceRow(accountName: 'Sales', debit: 0, credit: 485200),
    ReportTrialBalanceRow(accountName: 'Purchases', debit: 312800, credit: 0),
    ReportTrialBalanceRow(accountName: 'Rent Expense', debit: 36000, credit: 0),
    ReportTrialBalanceRow(accountName: 'Salary Expense', debit: 72000, credit: 0),
    ReportTrialBalanceRow(accountName: 'Capital Account', debit: 0, credit: 150550),
  ];

  static List<ReportBalanceSheetItem> balanceSheetAssets() => const [
    ReportBalanceSheetItem(name: 'Current Assets', isHeader: true, amount: 0),
    ReportBalanceSheetItem(name: 'Cash in Hand', amount: 45200, indent: 1),
    ReportBalanceSheetItem(name: 'Bank - HDFC', amount: 128500, indent: 1),
    ReportBalanceSheetItem(name: 'Sundry Debtors', amount: 76550, indent: 1),
    ReportBalanceSheetItem(name: 'Stock in Hand', amount: 89400, indent: 1),
    ReportBalanceSheetItem(name: 'Fixed Assets', isHeader: true, amount: 0),
    ReportBalanceSheetItem(name: 'Furniture & Fixtures', amount: 65000, indent: 1),
    ReportBalanceSheetItem(name: 'Computer Equipment', amount: 42000, indent: 1),
  ];

  static List<ReportBalanceSheetItem> balanceSheetLiabilities() => const [
    ReportBalanceSheetItem(name: 'Current Liabilities', isHeader: true, amount: 0),
    ReportBalanceSheetItem(name: 'Sundry Creditors', amount: 46900, indent: 1),
    ReportBalanceSheetItem(name: 'Outstanding Expenses', amount: 12400, indent: 1),
    ReportBalanceSheetItem(name: 'Capital & Reserves', isHeader: true, amount: 0),
    ReportBalanceSheetItem(name: 'Capital Account', amount: 150550, indent: 1),
    ReportBalanceSheetItem(name: 'Retained Earnings', amount: 18500, indent: 1),
  ];

  static double balanceSheetAssetsTotal() => 446650;
  static double balanceSheetLiabilitiesTotal() => 446650;

  // ── Party reports ────────────────────────────────────────────────────

  static List<ReportPartyStatementEntry> partyStatement(String partyId) {
    final partyIndex = PartyCatalog.parties.indexWhere((p) => p.id == partyId);
    if (partyIndex < 0) return [];

    final entries = <ReportPartyStatementEntry>[];
    var runningBalance = 0.0;
    var txnId = 1;

    for (var i = 0; i < 4 + (partyIndex % 3); i++) {
      final month = 3 + ((partyIndex + i) % 5);
      final day = ((partyIndex * 3 + i * 5) % 28) + 1;
      final amount = 2500 + ((txnId * 830) % 22000).toDouble();

      if (i.isEven) {
        runningBalance += amount;
        entries.add(
          ReportPartyStatementEntry(
            date: DateTime(2026, month, day),
            type: 'Sale',
            refNo: 'SI-${1000 + txnId}',
            total: amount,
            balance: runningBalance,
          ),
        );
      } else {
        final payment = amount * 0.6;
        runningBalance -= payment;
        entries.add(
          ReportPartyStatementEntry(
            date: DateTime(2026, month, day + 2),
            type: 'Payment In',
            refNo: 'PIN-${3000 + txnId}',
            total: payment,
            balance: runningBalance,
          ),
        );
      }
      txnId++;
    }

    return entries;
  }

  static ReportPartyStatementSummary partyStatementSummary(String partyId) {
    final party = PartyCatalog.parties.where((p) => p.id == partyId).firstOrNull;
    if (party == null) {
      return const ReportPartyStatementSummary(
        totalSale: 0,
        totalPurchase: 0,
        totalMoneyIn: 0,
        totalMoneyOut: 0,
        totalReceivable: 0,
      );
    }

    final entries = partyStatement(partyId);
    var totalSale = 0.0;
    var totalMoneyIn = 0.0;

    for (final entry in entries) {
      if (entry.type == 'Sale') totalSale += entry.total;
      if (entry.type == 'Payment In') totalMoneyIn += entry.total;
    }

    return ReportPartyStatementSummary(
      totalSale: totalSale,
      totalPurchase: totalSale * 0.35,
      totalMoneyIn: totalMoneyIn,
      totalMoneyOut: totalMoneyIn * 0.15,
      totalReceivable: party.balance > 0 ? party.balance : 0,
    );
  }

  static List<ReportPartyWiseProfitLossRow> partyWiseProfitLoss() {
    return PartyCatalog.parties.map((party) {
      final index = PartyCatalog.parties.indexOf(party);
      final saleAmount = 12000 + ((index + 1) * 3400) % 85000;
      final purchaseAmount = 8000 + ((index + 1) * 2100) % 52000;
      return ReportPartyWiseProfitLossRow(
        partyName: party.name,
        phone: party.phone,
        saleAmount: saleAmount.toDouble(),
        purchaseAmount: purchaseAmount.toDouble(),
        profit: (saleAmount - purchaseAmount).toDouble(),
      );
    }).toList();
  }

  static List<ReportSalePurchaseByPartyRow> salePurchaseByParty() {
    return PartyCatalog.parties.map((party) {
      final index = PartyCatalog.parties.indexOf(party);
      return ReportSalePurchaseByPartyRow(
        partyName: party.name,
        saleAmount: (8500 + ((index + 1) * 2800) % 62000).toDouble(),
        purchaseAmount: (5200 + ((index + 1) * 1900) % 38000).toDouble(),
      );
    }).toList();
  }

  static List<ReportSalePurchaseByPartyGroupRow> salePurchaseByPartyGroup() {
    final groups = defaultPartyGroups;
    final rows = <ReportSalePurchaseByPartyGroupRow>[];

    for (var i = 0; i < PartyCatalog.parties.length; i++) {
      final party = PartyCatalog.parties[i];
      rows.add(
        ReportSalePurchaseByPartyGroupRow(
          partyGroup: groups[i % groups.length],
          partyName: party.name,
          saleAmount: (6000 + ((i + 1) * 2200) % 45000).toDouble(),
          purchaseAmount: (4000 + ((i + 1) * 1500) % 28000).toDouble(),
        ),
      );
    }
    return rows;
  }

  static List<ReportPartyByItemRow> partyByItem(String itemName) {
    return List.generate(6, (index) {
      final party = PartyCatalog.parties[index];
      final qty = 2 + (index % 8);
      final price = 150 + ((index + 1) * 85) % 1200;
      return ReportPartyByItemRow(
        partyName: party.name,
        quantity: qty.toDouble(),
        amount: (qty * price).toDouble(),
      );
    });
  }

  // ── GST reports ──────────────────────────────────────────────────────

  static List<ReportGstrRow> gstr1SaleRows() {
    return List.generate(10, (index) {
      final party = PartyCatalog.parties[index];
      final taxable = 5000 + ((index + 1) * 1800) % 25000;
      final taxRate = _taxRates[index % _taxRates.length];
      final tax = taxable * taxRate / 100;
      return ReportGstrRow(
        gstin: _gstins[index % _gstins.length],
        partyName: party.name,
        invoiceNo: 'SI-${1001 + index}',
        date: DateTime(2026, 5 + (index % 2), (index % 28) + 1),
        value: taxable + tax,
        taxRate: taxRate,
        taxableValue: taxable.toDouble(),
        integratedTax: index.isEven ? tax : 0,
        cessRate: index % 5 == 0 ? 1 : 0,
      );
    });
  }

  static List<ReportGstrRow> gstr2PurchaseRows() {
    return List.generate(8, (index) {
      final party = PartyCatalog.parties[index + 2];
      final taxable = 4000 + ((index + 1) * 1500) % 20000;
      final taxRate = _taxRates[index % _taxRates.length];
      final tax = taxable * taxRate / 100;
      return ReportGstrRow(
        gstin: _gstins[(index + 3) % _gstins.length],
        partyName: party.name,
        invoiceNo: 'PI-${2001 + index}',
        date: DateTime(2026, 4 + (index % 3), (index % 28) + 1),
        value: taxable + tax,
        taxRate: taxRate,
        taxableValue: taxable.toDouble(),
        integratedTax: index.isOdd ? tax : 0,
      );
    });
  }

  static List<ReportSacRow> sacRows() {
    assert(_sacCodes.length >= 3);
    return const [
    ReportSacRow(
      sac: '998311',
      invoiceType: 'B2B',
      totalValue: 11800,
      taxableValue: 10000,
      igst: 1800,
      cgst: 0,
      sgst: 0,
      cess: 0,
    ),
    ReportSacRow(
      sac: '998313',
      invoiceType: 'B2B',
      totalValue: 23600,
      taxableValue: 20000,
      igst: 0,
      cgst: 1800,
      sgst: 1800,
      cess: 0,
    ),
    ReportSacRow(
      sac: '998314',
      invoiceType: 'B2C',
      totalValue: 5900,
      taxableValue: 5000,
      igst: 900,
      cgst: 0,
      sgst: 0,
      cess: 0,
    ),
    ReportSacRow(
      sac: '998311',
      invoiceType: 'B2B',
      totalValue: 17700,
      taxableValue: 15000,
      igst: 2700,
      cgst: 0,
      sgst: 0,
      cess: 0,
    ),
  ];
  }

  static double sacTotalValue() =>
      sacRows().fold(0.0, (sum, r) => sum + r.totalValue);

  static List<ReportHsnRow> hsnRows() {
    return List.generate(_hsnCodes.length, (index) {
      final (hsn, desc, uqc) = _hsnCodes[index];
      final qty = 10 + (index * 7);
      final taxable = 2000 + ((index + 1) * 3200) % 28000;
      final taxRate = _taxRates[index % _taxRates.length];
      final igst = index.isEven ? taxable * taxRate / 100 : 0.0;
      final cgst = index.isOdd ? taxable * taxRate / 200 : 0.0;
      final sgst = index.isOdd ? taxable * taxRate / 200 : 0.0;
      return ReportHsnRow(
        hsn: hsn,
        description: desc,
        uqc: uqc,
        quantity: qty.toDouble(),
        totalValue: taxable + igst + cgst + sgst,
        taxableValue: taxable.toDouble(),
        igst: igst,
        cgst: cgst,
        sgst: sgst,
      );
    });
  }

  static double hsnTotalValue() =>
      hsnRows().fold(0.0, (sum, r) => sum + r.totalValue);

  static List<ReportGstr3bRow> gstr3bRows() => const [
    ReportGstr3bRow(
      nature: '(a) Outward taxable supplies',
      taxableValue: 185400,
      integratedTax: 14832,
      centralTax: 6684,
      stateTax: 6684,
      cess: 0,
    ),
    ReportGstr3bRow(
      nature: '(b) Outward taxable supplies (zero rated)',
      taxableValue: 24000,
      integratedTax: 0,
      centralTax: 0,
      stateTax: 0,
      cess: 0,
    ),
    ReportGstr3bRow(
      nature: '(c) Other outward supplies (nil rated, exempted)',
      taxableValue: 8500,
      integratedTax: 0,
      centralTax: 0,
      stateTax: 0,
      cess: 0,
    ),
    ReportGstr3bRow(
      nature: '(d) Inward supplies (liable to reverse charge)',
      taxableValue: 6200,
      integratedTax: 1116,
      centralTax: 0,
      stateTax: 0,
      cess: 0,
    ),
  ];

  static List<ReportGstr9SupplyRow> gstr9SupplyRows() => const [
    ReportGstr9SupplyRow(
      label: 'Taxable',
      taxableValue: 485200,
      integratedTax: 38816,
      centralTax: 17468,
      stateTax: 17468,
      cess: 0,
    ),
    ReportGstr9SupplyRow(
      label: 'Zero rated',
      taxableValue: 24000,
      integratedTax: 0,
      centralTax: 0,
      stateTax: 0,
      cess: 0,
    ),
    ReportGstr9SupplyRow(
      label: 'Exempted',
      taxableValue: 12500,
      integratedTax: 0,
      centralTax: 0,
      stateTax: 0,
      cess: 0,
    ),
    ReportGstr9SupplyRow(
      label: 'Non-GST',
      taxableValue: 3200,
      integratedTax: 0,
      centralTax: 0,
      stateTax: 0,
      cess: 0,
    ),
  ];

  // ── Item / Stock reports ─────────────────────────────────────────────

  static List<ReportStockSummaryRow> stockSummary() {
    return InventoryCatalog.items.map((item) {
      final index = InventoryCatalog.items.indexOf(item);
      final salePrice = 120 + ((index + 1) * 85) % 2500;
      final purchasePrice = 80 + ((index + 1) * 60) % 1800;
      final qty = item.quantity ?? 0;
      return ReportStockSummaryRow(
        itemName: item.name,
        salePrice: salePrice.toDouble(),
        purchasePrice: purchasePrice.toDouble(),
        stockQty: qty,
        stockValue: qty > 0 ? qty * purchasePrice : 0,
        categoryId: item.categoryId ?? '',
      );
    }).toList();
  }

  static List<ReportItemByPartyRow> itemReportByParty() {
    return List.generate(8, (index) {
      final item = InventoryCatalog.items[index % InventoryCatalog.items.length];
      final party = PartyCatalog.parties[index];
      final qty = 1 + (index % 12);
      return ReportItemByPartyRow(
        itemName: item.name,
        partyName: party.name,
        quantity: qty.toDouble(),
        amount: (qty * (150 + index * 45)).toDouble(),
      );
    });
  }

  static List<ReportItemWiseProfitLossRow> itemWiseProfitLoss() {
    return InventoryCatalog.items.map((item) {
      final index = InventoryCatalog.items.indexOf(item);
      final sale = 5000 + ((index + 1) * 1800) % 42000;
      final purchase = 3500 + ((index + 1) * 1200) % 28000;
      return ReportItemWiseProfitLossRow(
        itemName: item.name,
        saleAmount: sale.toDouble(),
        purchaseAmount: purchase.toDouble(),
        profit: (sale - purchase).toDouble(),
      );
    }).toList();
  }

  static List<ReportLowStockRow> lowStock() {
    return InventoryCatalog.items
        .where((item) => (item.quantity ?? 0) <= 2)
        .map(
          (item) {
            final qty = item.quantity ?? 0;
            return ReportLowStockRow(
              itemName: item.name,
              minStock: 5,
              currentStock: qty,
              shortage: 5 - qty,
            );
          },
        )
        .toList();
  }

  static List<ReportStockDetailRow> stockDetail() {
    return InventoryCatalog.items.map((item) {
      final index = InventoryCatalog.items.indexOf(item);
      final opening = 10 + index * 2;
      final inbound = 5 + index;
      final outbound = 3 + (index % 4);
      return ReportStockDetailRow(
        itemName: item.name,
        openingQty: opening.toDouble(),
        inQty: inbound.toDouble(),
        outQty: outbound.toDouble(),
        closingQty: item.quantity ?? 0,
      );
    }).toList();
  }

  static List<ReportItemDetailRow> itemDetail(String itemName) {
    final item = InventoryCatalog.items
        .where((i) => i.name.toLowerCase() == itemName.toLowerCase())
        .firstOrNull;
    if (item == null) return [];

    return List.generate(5, (index) {
      final party = PartyCatalog.parties[index];
      final qty = 1 + (index % 5);
      final price = 150 + index * 30;
      return ReportItemDetailRow(
        date: DateTime(2026, 5, (index % 28) + 1),
        type: index.isEven ? 'Sale' : 'Purchase',
        refNo: index.isEven ? 'SI-${1100 + index}' : 'PI-${2100 + index}',
        partyName: party.name,
        quantity: qty.toDouble(),
        price: price.toDouble(),
        amount: (qty * price).toDouble(),
      );
    });
  }

  static List<ReportCategoryAmountRow> salePurchaseByCategory() {
    return InventoryCatalog.categories
        .where((c) => !c.isUncategorized)
        .map((cat) {
          final index = InventoryCatalog.categories.indexOf(cat);
          return ReportCategoryAmountRow(
            category: cat.name,
            saleAmount: (8000 + ((index + 1) * 4500) % 52000).toDouble(),
            purchaseAmount: (5000 + ((index + 1) * 2800) % 35000).toDouble(),
          );
        })
        .toList();
  }

  static List<ReportCategoryAmountRow> stockSummaryByCategory() {
    return InventoryCatalog.categories.map((cat) {
      final itemsInCat = InventoryCatalog.items
          .where((i) => i.categoryId == cat.id)
          .toList();
      final totalQty = itemsInCat.fold<double>(
        0,
        (sum, i) => sum + (i.quantity ?? 0),
      );
      final totalValue = itemsInCat.fold<double>(
        0,
        (sum, i) => sum + (i.stockValue ?? 0),
      );
      return ReportCategoryAmountRow(
        category: cat.name,
        saleAmount: totalQty,
        purchaseAmount: totalValue,
      );
    }).toList();
  }

  static List<ReportItemWiseProfitLossRow> categoryWiseProfitLoss() {
    return InventoryCatalog.categories
        .where((c) => !c.isUncategorized)
        .map((cat) {
          final index = InventoryCatalog.categories.indexOf(cat);
          final sale = 15000 + ((index + 1) * 6000) % 75000;
          final purchase = 10000 + ((index + 1) * 4000) % 48000;
          return ReportItemWiseProfitLossRow(
            itemName: cat.name,
            saleAmount: sale.toDouble(),
            purchaseAmount: purchase.toDouble(),
            profit: (sale - purchase).toDouble(),
          );
        })
        .toList();
  }

  static List<ReportItemDiscountRow> itemWiseDiscount() {
    return InventoryCatalog.items.map((item) {
      final index = InventoryCatalog.items.indexOf(item);
      final qty = 5 + (index % 20);
      final discount = 50 + ((index + 1) * 35) % 800;
      return ReportItemDiscountRow(
        itemName: item.name,
        saleQty: qty.toDouble(),
        discountAmount: discount.toDouble(),
        discountPercent: (discount / (qty * 200) * 100).clamp(1, 25),
      );
    }).toList();
  }

  static List<ReportManufacturingRow> manufacturing() {
    return List.generate(6, (index) {
      final item = InventoryCatalog.items[index % InventoryCatalog.items.length];
      return ReportManufacturingRow(
        date: DateTime(2026, 5, (index % 28) + 1),
        refNo: 'MFG-${100 + index}',
        itemName: item.name,
        quantity: (2 + index).toDouble(),
        cost: (1200 + index * 450).toDouble(),
      );
    });
  }

  static List<ReportConsumptionRow> consumption() {
    return List.generate(5, (index) {
      final item = InventoryCatalog.items[index % InventoryCatalog.items.length];
      return ReportConsumptionRow(
        date: DateTime(2026, 6, (index % 28) + 1),
        refNo: 'CON-${200 + index}',
        itemName: item.name,
        quantity: (1 + index % 4).toDouble(),
        value: (500 + index * 180).toDouble(),
      );
    });
  }

  static List<ReportStockTransferRow> stockTransfers() {
    return List.generate(4, (index) {
      final item = InventoryCatalog.items[index % InventoryCatalog.items.length];
      return ReportStockTransferRow(
        date: DateTime(2026, 6, (index % 28) + 1),
        refNo: 'ST-${300 + index}',
        fromGodown: _godowns[0],
        toGodown: _godowns[1],
        itemName: item.name,
        quantity: (3 + index).toDouble(),
      );
    });
  }

  // ── Expense reports ────────────────────────────────────────────────────

  static List<ReportExpenseRow> expenses() {
    return List.generate(_expenseItems.length, (index) {
      final (item, category) = _expenseItems[index];
      final amount = 1200 + ((index + 1) * 850) % 25000;
      final month = 5 + (index % 2);
      return ReportExpenseRow(
        date: DateTime(2026, month, (index % 28) + 1),
        expenseNo: 'EXP-${1001 + index}',
        partyName: PartyCatalog.partyNames[index % PartyCatalog.partyNames.length],
        category: category,
        amount: amount.toDouble(),
        dueDate: DateTime(2026, month, (index % 28) + 15),
        status: index.isEven ? 'Paid' : 'Unpaid',
      );
    });
  }

  static double expenseTotal() =>
      expenses().fold(0.0, (sum, r) => sum + r.amount);

  static List<ReportExpenseCategoryRow> expenseByCategory() {
    final map = <String, ({double amount, int count})>{};
    for (final expense in expenses()) {
      final existing = map[expense.category];
      map[expense.category] = (
        amount: (existing?.amount ?? 0) + expense.amount,
        count: (existing?.count ?? 0) + 1,
      );
    }
    return map.entries
        .map(
          (e) => ReportExpenseCategoryRow(
            category: e.key,
            amount: e.value.amount,
            count: e.value.count,
          ),
        )
        .toList();
  }

  static List<ReportExpenseItemRow> expenseByItem() {
    final map = <String, ({String category, double amount, int count})>{};
    for (final (item, category) in _expenseItems) {
      final expense = expenses().where((e) => e.category == category).firstOrNull;
      final amount = expense?.amount ?? 0;
      map[item] = (
        category: category,
        amount: amount,
        count: 1,
      );
    }
    return map.entries
        .map(
          (e) => ReportExpenseItemRow(
            itemName: e.key,
            category: e.value.category,
            amount: e.value.amount,
            count: e.value.count,
          ),
        )
        .toList();
  }

  // ── Business status ──────────────────────────────────────────────────

  static List<ReportBankStatementRow> bankStatement(String bank) {
    if (bank == 'Select bank account' || !_banks.contains(bank)) return [];

    final rows = <ReportBankStatementRow>[
      ReportBankStatementRow(
        date: DateTime(2026, 7, 1),
        description: 'Bank balance forward',
        refNo: '-',
        moneyIn: 0,
        moneyOut: 0,
        balance: 98500,
        isOpening: true,
      ),
    ];

    var balance = 98500.0;
    final transactions = [
      ('Payment received - Sharma Traders', 'PIN-3010', 18500.0, 0.0),
      ('Payment received - Patel Electronics', 'PIN-3011', 12400.0, 0.0),
      ('Rent payment', 'EXP-1001', 0.0, 36000.0),
      ('Supplier payment - Mehta Hardware', 'PO-2015', 0.0, 15600.0),
      ('UPI collection - Kumar Agencies', 'PIN-3012', 9200.0, 0.0),
      ('Electricity bill', 'EXP-1002', 0.0, 4200.0),
      ('Cheque deposit - Reddy Mart', 'PIN-3013', 28750.0, 0.0),
    ];

    for (var i = 0; i < transactions.length; i++) {
      final (desc, ref, moneyIn, moneyOut) = transactions[i];
      balance += moneyIn - moneyOut;
      rows.add(
        ReportBankStatementRow(
          date: DateTime(2026, 7, 3 + i * 4),
          description: desc,
          refNo: ref,
          moneyIn: moneyIn,
          moneyOut: moneyOut,
          balance: balance,
        ),
      );
    }

    return rows;
  }

  // ── Sale / Purchase orders ─────────────────────────────────────────────

  static List<ReportOrderRow> orders() {
    return List.generate(10, (index) {
      final party = PartyCatalog.parties[index];
      final amount = 4500 + ((index + 1) * 1200) % 28000;
      final isSale = index.isEven;
      return ReportOrderRow(
        date: DateTime(2026, 6, (index % 28) + 1),
        orderNo: isSale ? 'SO-${1001 + index}' : 'PO-${2001 + index}',
        partyName: party.name,
        dueDate: DateTime(2026, 6, (index % 28) + 15),
        status: ['Open', 'Partial', 'Completed'][index % 3],
        type: isSale ? 'Sale Order' : 'Purchase Order',
        amount: amount.toDouble(),
      );
    });
  }

  static double ordersTotal() =>
      orders().fold(0.0, (sum, r) => sum + r.amount);

  static List<ReportOrderItemRow> orderItems() {
    return List.generate(12, (index) {
      final item = InventoryCatalog.items[index % InventoryCatalog.items.length];
      final party = PartyCatalog.parties[index % PartyCatalog.parties.length];
      final qty = 2 + (index % 8);
      return ReportOrderItemRow(
        itemName: item.name,
        orderNo: index.isEven ? 'SO-${1001 + index}' : 'PO-${2001 + index}',
        partyName: party.name,
        quantity: qty.toDouble(),
        amount: (qty * (200 + index * 50)).toDouble(),
      );
    });
  }

  static double orderItemsTotal() =>
      orderItems().fold(0.0, (sum, r) => sum + r.amount);

  // ── Taxes reports ──────────────────────────────────────────────────────

  static List<ReportGstTaxPartyRow> gstTaxByParty() => [
        const ReportGstTaxPartyRow(
          partyName: 'KK INDUSTRIES',
          saleTax: 0,
          purchaseExpenseTax: 62.34,
        ),
        const ReportGstTaxPartyRow(
          partyName: 'new party',
          saleTax: 0,
          purchaseExpenseTax: 0,
        ),
        const ReportGstTaxPartyRow(
          partyName: 'test sale',
          saleTax: 0,
          purchaseExpenseTax: 0,
        ),
        for (var i = 0; i < 3; i++)
          ReportGstTaxPartyRow(
            partyName: PartyCatalog.partyNames[i],
            saleTax: i.isEven ? 180.0 + i * 45 : 0,
            purchaseExpenseTax: i.isOdd ? 95.0 + i * 30 : 0,
          ),
      ];

  static List<ReportGstTaxRateRow> gstTaxRateRows() => const [
        ReportGstTaxRateRow(
          taxName: 'IGST@0.25%',
          taxPercent: 0.25,
          taxableSaleAmount: 0,
          taxIn: 0,
          taxablePurchaseExpenseAmount: 24937.66,
          taxOut: 62.34,
        ),
        ReportGstTaxRateRow(
          taxName: 'IGST@5%',
          taxPercent: 5,
          taxableSaleAmount: 12500,
          taxIn: 625,
          taxablePurchaseExpenseAmount: 8200,
          taxOut: 410,
        ),
        ReportGstTaxRateRow(
          taxName: 'CGST@9%',
          taxPercent: 9,
          taxableSaleAmount: 9800,
          taxIn: 882,
          taxablePurchaseExpenseAmount: 6400,
          taxOut: 576,
        ),
        ReportGstTaxRateRow(
          taxName: 'SGST@9%',
          taxPercent: 9,
          taxableSaleAmount: 9800,
          taxIn: 882,
          taxablePurchaseExpenseAmount: 6400,
          taxOut: 576,
        ),
      ];

  // ── Other income reports ───────────────────────────────────────────────

  static List<ReportOtherIncomeRow> otherIncomes() {
    return List.generate(_otherIncomeItems.length, (index) {
      final (item, category) = _otherIncomeItems[index];
      final amount = 800 + ((index + 1) * 650) % 18000;
      final month = 5 + (index % 2);
      return ReportOtherIncomeRow(
        date: DateTime(2026, month, (index % 28) + 1),
        incomeNo: 'OIN-${1001 + index}',
        partyName: PartyCatalog.partyNames[index % PartyCatalog.partyNames.length],
        category: category,
        paymentType: ['Cash', 'Bank Transfer', 'UPI', 'Cheque'][index % 4],
        amount: amount.toDouble(),
        dueDate: DateTime(2026, month, (index % 28) + 10),
        status: index.isEven ? 'Received' : 'Pending',
      );
    });
  }

  static double otherIncomeTotal() =>
      otherIncomes().fold(0.0, (sum, r) => sum + r.amount);

  static List<ReportOtherIncomeCategoryRow> otherIncomeByCategory() {
    final map = <String, ({double amount, int count})>{};
    for (final income in otherIncomes()) {
      final existing = map[income.category];
      map[income.category] = (
        amount: (existing?.amount ?? 0) + income.amount,
        count: (existing?.count ?? 0) + 1,
      );
    }
    return map.entries
        .map(
          (e) => ReportOtherIncomeCategoryRow(
            category: e.key,
            amount: e.value.amount,
            count: e.value.count,
          ),
        )
        .toList();
  }

  static List<ReportOtherIncomeItemRow> otherIncomeByItem() {
    final map = <String, ({String category, double amount, int count})>{};
    for (final (item, category) in _otherIncomeItems) {
      final income =
          otherIncomes().where((e) => e.category == category).firstOrNull;
      final amount = income?.amount ?? 0;
      map[item] = (
        category: category,
        amount: amount,
        count: 1,
      );
    }
    return map.entries
        .map(
          (e) => ReportOtherIncomeItemRow(
            itemName: e.key,
            category: e.value.category,
            amount: e.value.amount,
            count: e.value.count,
          ),
        )
        .toList();
  }

  // ── Loan accounts ──────────────────────────────────────────────────────

  static List<ReportLoanStatementRow> loanStatement(String loanAccount) {
    if (loanAccount == 'Select loan account' ||
        !_loanAccounts.contains(loanAccount)) {
      return [];
    }

    final rows = <ReportLoanStatementRow>[
      ReportLoanStatementRow(
        date: DateTime(2026, 7, 1),
        description: 'Opening balance',
        refNo: '-',
        debit: 0,
        credit: 0,
        balance: 250000,
        isOpening: true,
      ),
    ];

    var balance = 250000.0;
    final transactions = [
      ('EMI payment - July', 'EMI-2407', 0.0, 18500.0),
      ('Interest charged', 'INT-2407', 4200.0, 0.0),
      ('Additional disbursement', 'DISB-001', 50000.0, 0.0),
      ('EMI payment - August', 'EMI-2408', 0.0, 18500.0),
      ('Interest charged', 'INT-2408', 3950.0, 0.0),
      ('Principal prepayment', 'PREP-001', 0.0, 25000.0),
    ];

    for (var i = 0; i < transactions.length; i++) {
      final (desc, ref, debit, credit) = transactions[i];
      balance += debit - credit;
      rows.add(
        ReportLoanStatementRow(
          date: DateTime(2026, 7, 5 + i * 5),
          description: desc,
          refNo: ref,
          debit: debit,
          credit: credit,
          balance: balance,
        ),
      );
    }

    return rows;
  }

  // ── Cash flow helpers ──────────────────────────────────────────────────

  static double cashFlowOpening() => 45200;
  static double cashFlowClosing() => 52850;

  static String _statusLabel(SaleInvoiceStatus status) => switch (status) {
    SaleInvoiceStatus.paid => 'Paid',
    SaleInvoiceStatus.unpaid => 'Unpaid',
    SaleInvoiceStatus.partiallyPaid => 'Partial',
    SaleInvoiceStatus.overdue => 'Overdue',
    SaleInvoiceStatus.cancelled => 'Cancelled',
  };
}
