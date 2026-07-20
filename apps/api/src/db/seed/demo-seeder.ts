import { eq } from 'drizzle-orm';
import { PaymentService } from '../../modules/accounting/payment.service';
import { AuthRepository } from '../../modules/auth/auth.repository';
import { BusinessService } from '../../modules/business/business.service';
import { CategoryService } from '../../modules/inventory/category.service';
import { ItemService } from '../../modules/inventory/item.service';
import { UnitService } from '../../modules/inventory/unit.service';
import { PartyService } from '../../modules/parties/party.service';
import { ExpenseService } from '../../modules/purchases/expense.service';
import { PurchaseDocumentService } from '../../modules/purchases/purchase-document.service';
import { SalesDocumentService } from '../../modules/sales/sales-document.service';
import { currentFiscalYear } from '../../modules/sales/sales-numbering.service';
import {
  DEV_ACCOUNT_NAME,
  DEV_BUSINESS_ADDRESS,
  DEV_BUSINESS_GSTIN,
  DEV_BUSINESS_NAME,
  DEV_BUSINESS_PHONE,
  DEV_BUSINESS_STATE,
  DEV_BUSINESS_STATE_CODE,
  DEV_LOGIN_PHONE,
} from '../../shared/dev-demo.constants';
import type { Database } from '../client';
import { businesses } from '../schema/business/tables';
import { users } from '../schema/identity/tables';
import { godowns } from '../schema/inventory/tables';
import { expenseCategories } from '../schema/purchases/tables';
import { SYSTEM_EXPENSE_CATEGORIES } from '../../modules/purchases/expense-category.constants';
import { ensureSystemExpenseCategories } from '../../modules/purchases/expense-sync.service';
import {
  businessSettings,
  documentNumberSequences,
} from '../schema/settings/tables';
import {
  DEMO_CATEGORIES,
  DEMO_CUSTOMERS,
  DEMO_EXPENSES,
  DEMO_PRODUCTS,
  DEMO_SUPPLIERS,
  DEMO_UNITS,
  type DemoPartySeed,
  type DemoProductSeed,
} from './demo-data';
import { resetBusinessData } from './reset-business';

async function deleteBusinessCompletely(
  db: Database,
  businessId: string,
): Promise<void> {
  await resetBusinessData(db, businessId);
  await db
    .delete(businessSettings)
    .where(eq(businessSettings.businessId, businessId));
  await db
    .delete(expenseCategories)
    .where(eq(expenseCategories.businessId, businessId));
  await db.delete(users).where(eq(users.businessId, businessId));
  await db.delete(businesses).where(eq(businesses.id, businessId));
}

export type SeedContext = {
  businessId: string;
  accountId: string;
  userId: string;
};

type SeededItem = {
  id: string;
  name: string;
  unit: string;
  salePrice: string;
  taxRate: string;
};

type SeededParty = {
  id: string;
  name: string;
  stateCode: string;
};

type SeededInvoice = {
  id: string;
  partyId: string;
  totalAmount: string;
};

type SeededPurchase = {
  id: string;
  partyId: string;
  totalAmount: string;
};

function documentLine(item: SeededItem, quantity: string) {
  return {
    item_id: item.id,
    quantity,
    unit: item.unit,
    unit_price: item.salePrice,
    discount_amount: '0',
    tax_type: 'cgst_sgst' as const,
    tax_rate: item.taxRate,
  };
}

function purchaseDocumentLine(item: SeededItem, quantity: string) {
  return {
    ...documentLine(item, quantity),
    tax_inclusive: false,
  };
}

function daysAgoIso(days: number): string {
  const date = new Date();
  date.setDate(date.getDate() - days);
  date.setHours(10, 30, 0, 0);
  return date.toISOString();
}

function daysAgoDate(days: number): string {
  const date = new Date();
  date.setDate(date.getDate() - days);
  return date.toISOString().slice(0, 10);
}

async function bootstrapBusinessEssentials(
  db: Database,
  businessId: string,
): Promise<string> {
  const fiscalYear = currentFiscalYear();

  const [existingGodown] = await db
    .select({ id: godowns.id })
    .from(godowns)
    .where(eq(godowns.businessId, businessId))
    .limit(1);

  let godownId = existingGodown?.id;
  if (!godownId) {
    const [created] = await db
      .insert(godowns)
      .values({
        businessId,
        name: 'Main Warehouse',
        address: 'Ground Floor, Laxmi Market, FC Road, Pune',
        isDefault: true,
      })
      .returning({ id: godowns.id });
    godownId = created?.id;
  }

  if (!godownId) {
    throw new Error('Failed to bootstrap default godown');
  }

  const [settings] = await db
    .select({ id: businessSettings.id })
    .from(businessSettings)
    .where(eq(businessSettings.businessId, businessId))
    .limit(1);

  if (!settings) {
    await db.insert(businessSettings).values({
      businessId,
      valuationMethod: 'average',
      defaultTaxType: 'none',
      enablePriceConflictAlerts: true,
      creditLimitAction: 'warn',
    });
  }

  await ensureSystemExpenseCategories(db, businessId);

  const sequences = [
    { documentSeries: 'INV', prefix: 'INV' },
    { documentSeries: 'PUR', prefix: 'PUR' },
    { documentSeries: 'SR', prefix: 'SR' },
    { documentSeries: 'PR', prefix: 'PR' },
  ];

  const existingSequences = await db
    .select({ documentSeries: documentNumberSequences.documentSeries })
    .from(documentNumberSequences)
    .where(eq(documentNumberSequences.businessId, businessId));
  const existingSeries = new Set(
    existingSequences.map((row) => row.documentSeries),
  );

  for (const sequence of sequences) {
    if (existingSeries.has(sequence.documentSeries)) {
      continue;
    }

    await db.insert(documentNumberSequences).values({
      businessId,
      documentSeries: sequence.documentSeries,
      prefix: sequence.prefix,
      nextNumber: 1,
      fiscalYear,
    });
  }

  return godownId;
}

async function ensureDemoAccount(
  db: Database,
): Promise<{ accountId: string; businessId: string; userId: string }> {
  const authRepository = new AuthRepository(db);

  let account = await authRepository.findAccountByPhone(DEV_LOGIN_PHONE);
  if (!account) {
    account = await authRepository.createAccount(
      DEV_LOGIN_PHONE,
      DEV_ACCOUNT_NAME,
    );
  } else if (account.name !== DEV_ACCOUNT_NAME) {
    account = await authRepository.updateAccountName(
      account.id,
      DEV_ACCOUNT_NAME,
    );
  }

  let memberships = await authRepository.findMembershipsByAccountId(account.id);

  if (memberships.length > 1) {
    const [primary, ...extras] = memberships;
    for (const extra of extras) {
      await deleteBusinessCompletely(db, extra.businessId);
    }
    memberships = primary ? [primary] : [];
  }

  if (memberships.length === 0) {
    const membership = await authRepository.createBusinessWithOwner({
      accountId: account.id,
      businessName: DEV_BUSINESS_NAME,
      ownerName: DEV_ACCOUNT_NAME,
      phone: DEV_BUSINESS_PHONE,
    });
    memberships = [membership];
  }

  const membership = memberships[0];
  if (!membership) {
    throw new Error('Failed to resolve demo business membership');
  }

  return {
    accountId: account.id,
    businessId: membership.businessId,
    userId: membership.userId,
  };
}

async function updateBusinessProfile(
  db: Database,
  ctx: SeedContext,
): Promise<void> {
  const businessService = new BusinessService();
  await businessService.updateProfile(ctx.businessId, ctx.accountId, {
    name: DEV_BUSINESS_NAME,
    phone: DEV_BUSINESS_PHONE,
    email: undefined,
    gstin: DEV_BUSINESS_GSTIN,
    state: DEV_BUSINESS_STATE,
    address: DEV_BUSINESS_ADDRESS,
    business_type: 'Retail',
    business_category: 'General Store',
    pincode: '411004',
  });

  await db
    .update(businesses)
    .set({
      stateCode: DEV_BUSINESS_STATE_CODE,
      updatedAt: new Date(),
    })
    .where(eq(businesses.id, ctx.businessId));
}

async function seedUnits(ctx: SeedContext): Promise<Map<string, string>> {
  const unitService = new UnitService();
  const unitMap = new Map<string, string>();

  for (const unit of DEMO_UNITS) {
    const created = await unitService.createUnit(
      ctx.businessId,
      ctx.accountId,
      ctx.userId,
      {
        name: unit.name,
        short_name: unit.shortName,
        symbol: undefined,
        decimal_places: 0,
        is_system: false,
        is_active: true,
      },
    );
    unitMap.set(unit.shortName, created.short_name);
  }

  console.log(`  Units: ${unitMap.size}`);
  return unitMap;
}

async function seedCategories(ctx: SeedContext): Promise<Map<string, string>> {
  const categoryService = new CategoryService();
  const categoryMap = new Map<string, string>();

  for (const name of DEMO_CATEGORIES) {
    const created = await categoryService.createCategory(
      ctx.businessId,
      ctx.accountId,
      ctx.userId,
      { name },
    );
    categoryMap.set(name, created.id);
  }

  console.log(`  Categories: ${categoryMap.size}`);
  return categoryMap;
}

async function seedParty(
  ctx: SeedContext,
  partyService: PartyService,
  seed: DemoPartySeed,
): Promise<SeededParty> {
  const created = await partyService.createParty(
    ctx.businessId,
    ctx.accountId,
    ctx.userId,
    {
      name: seed.name,
      mobile: seed.mobile,
      email: undefined,
      party_type: seed.partyType,
      party_category: seed.partyCategory,
      pricing_tier: 'tier_1',
      state: seed.state,
      state_code: seed.stateCode,
      credit_limit: seed.creditLimit,
      opening_balance: '0',
      notes: `Address: ${seed.address}`,
      currency: undefined,
      is_active: true,
      gstin: seed.gstin,
    },
  );

  return {
    id: created.id,
    name: created.name,
    stateCode: seed.stateCode,
  };
}

async function seedParties(ctx: SeedContext): Promise<{
  customers: SeededParty[];
  suppliers: SeededParty[];
}> {
  const partyService = new PartyService();
  const customers: SeededParty[] = [];
  const suppliers: SeededParty[] = [];

  for (const customer of DEMO_CUSTOMERS) {
    customers.push(await seedParty(ctx, partyService, customer));
  }

  for (const supplier of DEMO_SUPPLIERS) {
    suppliers.push(await seedParty(ctx, partyService, supplier));
  }

  console.log(
    `  Parties: ${customers.length} customers, ${suppliers.length} suppliers`,
  );
  return { customers, suppliers };
}

async function seedProduct(
  ctx: SeedContext,
  itemService: ItemService,
  product: DemoProductSeed,
  categoryMap: Map<string, string>,
  godownId: string,
): Promise<SeededItem> {
  const isService = product.category === 'Services';
  const openingQty = isService ? undefined : product.openingQty;

  const created = await itemService.createItem(
    ctx.businessId,
    ctx.accountId,
    ctx.userId,
    {
      name: product.name,
      description: undefined,
      item_type: isService ? 'service' : 'product',
      category_id: categoryMap.get(product.category),
      barcode: product.barcode,
      hsn_code: product.hsn,
      base_unit: product.unit,
      sale_price: product.salePrice,
      purchase_price: product.purchasePrice,
      reorder_level: isService ? undefined : product.reorderLevel,
      has_stock_tracking: !isService,
      tier_prices: [],
      primary_image_url: undefined,
      opening_quantity: openingQty,
      opening_cost_per_unit: isService ? undefined : product.purchasePrice,
      opening_godown_id: isService ? undefined : godownId,
    },
  );

  return {
    id: created.id,
    name: created.name,
    unit: product.unit,
    salePrice: product.salePrice,
    taxRate: product.taxRate,
  };
}

async function seedProducts(
  ctx: SeedContext,
  categoryMap: Map<string, string>,
  godownId: string,
): Promise<SeededItem[]> {
  const itemService = new ItemService();
  const items: SeededItem[] = [];

  for (const product of DEMO_PRODUCTS) {
    items.push(
      await seedProduct(ctx, itemService, product, categoryMap, godownId),
    );
  }

  console.log(`  Products: ${items.length}`);
  return items;
}

async function createPurchaseBill(
  ctx: SeedContext,
  purchaseService: PurchaseDocumentService,
  supplier: SeededParty,
  items: SeededItem[],
  itemIndexes: number[],
  daysAgo: number,
): Promise<SeededPurchase> {
  const document = await purchaseService.createDocument(
    ctx.businessId,
    ctx.accountId,
    ctx.userId,
    {
      document_type: 'purchase_bill',
      document_series: 'PUR',
      party_id: supplier.id,
      is_gst_formal: true,
      party_state_code: supplier.stateCode,
      document_date: daysAgoIso(daysAgo),
      due_date: daysAgoDate(Math.max(daysAgo - 15, 1)),
    },
  );

  for (const index of itemIndexes) {
    const item = items[index];
    if (!item) continue;

    await purchaseService.addLine(
      ctx.businessId,
      ctx.accountId,
      ctx.userId,
      document.id,
      purchaseDocumentLine(item, String(5 + (index % 8))),
    );
  }

  await purchaseService.finalizeDocument(
    ctx.businessId,
    ctx.accountId,
    ctx.userId,
    document.id,
    {},
  );

  const finalized = await purchaseService.getDocument(
    ctx.businessId,
    ctx.accountId,
    document.id,
  );

  return {
    id: finalized.id,
    partyId: supplier.id,
    totalAmount: finalized.total_amount,
  };
}

async function seedPurchases(
  ctx: SeedContext,
  suppliers: SeededParty[],
  items: SeededItem[],
): Promise<SeededPurchase[]> {
  const purchaseService = new PurchaseDocumentService();
  const purchases: SeededPurchase[] = [];
  const stockItems = items.filter((item) => item.unit !== 'Svc');

  for (let i = 0; i < 15; i++) {
    const supplier = suppliers[i % suppliers.length];
    if (!supplier) continue;

    const itemA = i % stockItems.length;
    const itemB = (i + 3) % stockItems.length;
    const itemC = (i + 7) % stockItems.length;

    purchases.push(
      await createPurchaseBill(
        ctx,
        purchaseService,
        supplier,
        stockItems,
        [itemA, itemB, itemC],
        45 - i * 2,
      ),
    );
  }

  console.log(`  Purchase bills: ${purchases.length}`);
  return purchases;
}

async function createSalesInvoice(
  ctx: SeedContext,
  salesService: SalesDocumentService,
  customer: SeededParty,
  items: SeededItem[],
  itemIndexes: number[],
  daysAgo: number,
  _quantities?: number[],
): Promise<SeededInvoice> {
  const document = await salesService.createDocument(
    ctx.businessId,
    ctx.accountId,
    ctx.userId,
    {
      document_type: 'tax_invoice',
      document_series: 'INV',
      party_id: customer.id,
      is_gst_formal: true,
      party_state_code: customer.stateCode,
      document_date: daysAgoIso(daysAgo),
    },
  );

  for (const index of itemIndexes) {
    const item = items[index];
    if (!item || item.unit === 'Svc') continue;

    await salesService.addLine(
      ctx.businessId,
      ctx.accountId,
      ctx.userId,
      document.id,
      documentLine(item, String(2 + (index % 5))),
    );
  }

  await salesService.finalizeDocument(
    ctx.businessId,
    ctx.accountId,
    ctx.userId,
    document.id,
    {},
  );

  const finalized = await salesService.getDocument(
    ctx.businessId,
    ctx.accountId,
    document.id,
  );

  return {
    id: finalized.id,
    partyId: customer.id,
    totalAmount: finalized.total_amount,
  };
}

async function seedSales(
  ctx: SeedContext,
  customers: SeededParty[],
  items: SeededItem[],
): Promise<SeededInvoice[]> {
  const salesService = new SalesDocumentService();
  const invoices: SeededInvoice[] = [];
  const stockItems = items.filter((item) => item.unit !== 'Svc');

  for (let i = 0; i < 25; i++) {
    const customer = customers[i % customers.length];
    if (!customer) continue;

    const itemA = i % stockItems.length;
    const itemB = (i + 5) % stockItems.length;

    invoices.push(
      await createSalesInvoice(
        ctx,
        salesService,
        customer,
        stockItems,
        [itemA, itemB],
        60 - i * 2,
      ),
    );
  }

  // Sales returns
  for (let i = 0; i < 3; i++) {
    const customer = customers[i];
    const item = stockItems[i * 4];
    if (!customer || !item) continue;

    const salesReturn = await salesService.createDocument(
      ctx.businessId,
      ctx.accountId,
      ctx.userId,
      {
        document_type: 'sales_return',
        document_series: 'SR',
        party_id: customer.id,
        is_gst_formal: true,
        party_state_code: customer.stateCode,
        document_date: daysAgoIso(8 + i),
      },
    );

    await salesService.addLine(
      ctx.businessId,
      ctx.accountId,
      ctx.userId,
      salesReturn.id,
      documentLine(item, '1'),
    );

    await salesService.finalizeDocument(
      ctx.businessId,
      ctx.accountId,
      ctx.userId,
      salesReturn.id,
      {},
    );
  }

  console.log(`  Sales invoices: ${invoices.length} (+ 3 returns)`);
  return invoices;
}

async function seedPayments(
  ctx: SeedContext,
  customers: SeededParty[],
  suppliers: SeededParty[],
  invoices: SeededInvoice[],
  purchases: SeededPurchase[],
): Promise<void> {
  const paymentService = new PaymentService();
  const paymentModes = ['cash', 'upi', 'bank_transfer', 'card'] as const;

  // Payment in — 10 receipts, mix of allocated and unallocated
  for (let i = 0; i < 10; i++) {
    const customer = customers[i % customers.length];
    const invoice = invoices[i];
    if (!customer) continue;

    const amount = invoice
      ? i < 6
        ? invoice.totalAmount
        : String(Math.max(500, Math.floor(Number(invoice.totalAmount) * 0.5)))
      : '2500';

    await paymentService.createPayment(
      ctx.businessId,
      ctx.accountId,
      ctx.userId,
      {
        party_id: customer.id,
        direction: 'received',
        amount,
        payment_mode: paymentModes[i % paymentModes.length] ?? 'cash',
        payment_date: daysAgoIso(30 - i * 2),
        reference_number: `RCPT-${1001 + i}`,
        source: 'manual',
        allocations:
          invoice && i < 8
            ? [
                {
                  sales_document_id: invoice.id,
                  allocated_amount: amount,
                },
              ]
            : [],
      },
    );
  }

  // Payment out — 10 supplier payments
  for (let i = 0; i < 10; i++) {
    const supplier = suppliers[i % suppliers.length];
    const purchase = purchases[i];
    if (!supplier) continue;

    const amount = purchase
      ? i < 7
        ? purchase.totalAmount
        : String(Math.max(1000, Math.floor(Number(purchase.totalAmount) * 0.6)))
      : '5000';

    await paymentService.createPayment(
      ctx.businessId,
      ctx.accountId,
      ctx.userId,
      {
        party_id: supplier.id,
        direction: 'paid',
        amount,
        payment_mode: paymentModes[(i + 1) % paymentModes.length] ?? 'upi',
        payment_date: daysAgoIso(40 - i * 3),
        reference_number: `PAY-${2001 + i}`,
        source: 'manual',
        allocations:
          purchase && i < 8
            ? [
                {
                  purchase_document_id: purchase.id,
                  allocated_amount: amount,
                },
              ]
            : [],
      },
    );
  }

  console.log('  Payments: 10 in, 10 out');
}

async function seedExpenses(ctx: SeedContext, db: Database): Promise<void> {
  const expenseService = new ExpenseService();
  const categories = await db
    .select({ id: expenseCategories.id, name: expenseCategories.name })
    .from(expenseCategories)
    .where(eq(expenseCategories.businessId, ctx.businessId));

  const categoryByName = new Map(
    categories.map((row) => [row.name, row.id] as const),
  );

  for (const expense of DEMO_EXPENSES) {
    const categoryId = categoryByName.get(expense.category);
    if (!categoryId) continue;

    await expenseService.createExpense(
      ctx.businessId,
      ctx.accountId,
      ctx.userId,
      {
        category_id: categoryId,
        amount: expense.amount,
        description: expense.description,
        expense_date: daysAgoDate(expense.daysAgo),
        payment_mode: expense.paymentMode,
      },
    );
  }

  console.log(`  Expenses: ${DEMO_EXPENSES.length}`);
}

export async function seedDemoData(db: Database): Promise<SeedContext> {
  console.log('Preparing demo account and business...');
  const { accountId, businessId, userId } = await ensureDemoAccount(db);
  const ctx: SeedContext = { businessId, accountId, userId };

  console.log('Resetting existing business data...');
  await resetBusinessData(db, businessId);

  console.log('Bootstrapping essentials...');
  const godownId = await bootstrapBusinessEssentials(db, businessId);

  console.log('Updating business profile...');
  await updateBusinessProfile(db, ctx);

  console.log('Seeding master data...');
  await seedUnits(ctx);
  const categoryMap = await seedCategories(ctx);
  const { customers, suppliers } = await seedParties(ctx);
  const items = await seedProducts(ctx, categoryMap, godownId);

  console.log('Seeding transactions...');
  const purchases = await seedPurchases(ctx, suppliers, items);
  const invoices = await seedSales(ctx, customers, items);
  await seedPayments(ctx, customers, suppliers, invoices, purchases);
  await seedExpenses(ctx, db);

  console.log('Demo seed complete for business:', businessId);
  return ctx;
}
