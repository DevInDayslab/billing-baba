import {
  allocationIdParamSchema,
  createAllocationBodySchema,
  createPaymentBodySchema,
  listPaymentsQuerySchema,
  paymentIdParamSchema,
  updatePaymentBodySchema,
} from '../modules/accounting/payment.schema';
import {
  loginBodySchema,
  logoutBodySchema,
  refreshBodySchema,
} from '../modules/auth/auth.schema';
import {
  createBusinessBodySchema,
  updateBusinessProfileBodySchema,
} from '../modules/business/business.schema';
import {
  companyMemberIdParamsSchema,
  createInvitationBodySchema,
  invitationIdParamsSchema,
  invitationTokenParamsSchema,
  updateCompanyMemberBodySchema,
} from '../modules/collaboration/collaboration.schema';
import { dashboardQuerySchema } from '../modules/dashboard/dashboard.schema';
import {
  createBrandBodySchema,
  listBrandsQuerySchema,
  updateBrandBodySchema,
} from '../modules/inventory/brand.schema';
import {
  createCategoryBodySchema,
  listCategoriesQuerySchema,
  updateCategoryBodySchema,
} from '../modules/inventory/category.schema';
import {
  createGodownBodySchema,
  listGodownsQuerySchema,
  updateGodownBodySchema,
} from '../modules/inventory/godown.schema';
import {
  createItemBodySchema,
  createItemImageBodySchema,
  itemIdParamSchema,
  itemImageParamSchema,
  itemTierParamSchema,
  listItemPriceHistoryQuerySchema,
  listItemsQuerySchema,
  putItemTierPricesBodySchema,
  updateItemBodySchema,
  updateItemImageBodySchema,
} from '../modules/inventory/item.schema';
import {
  createItemLocationBodySchema,
  listItemLocationsQuerySchema,
  updateItemLocationBodySchema,
} from '../modules/inventory/item-location.schema';
import {
  createMovementBodySchema,
  listMovementsQuerySchema,
} from '../modules/inventory/movement.schema';
import { listPriceHistoryQuerySchema } from '../modules/inventory/price-history.schema';
import { listStockLevelsQuerySchema } from '../modules/inventory/stock-level.schema';
import {
  createUnitBodySchema,
  createUnitConversionBodySchema,
  listUnitConversionsQuerySchema,
  listUnitsQuerySchema,
  updateUnitBodySchema,
  updateUnitConversionBodySchema,
} from '../modules/inventory/unit.schema';
import {
  createJobWorkOrderBodySchema,
  listJobWorkOrdersQuerySchema,
  updateJobWorkOrderBodySchema,
} from '../modules/job-work/job-work-order.schema';
import {
  createPartyBodySchema,
  listPartiesQuerySchema,
  updatePartyBodySchema,
} from '../modules/parties/party.schema';
import {
  createExpenseBodySchema,
  listExpensesQuerySchema,
  updateExpenseBodySchema,
} from '../modules/purchases/expense.schema';
import {
  createExpenseCategoryBodySchema,
  listExpenseCategoriesQuerySchema,
  updateExpenseCategoryBodySchema,
} from '../modules/purchases/expense-category.schema';
import {
  convertPurchaseDocumentBodySchema,
  createPurchaseDocumentBodySchema,
  createPurchaseLineBodySchema,
  finalizePurchaseDocumentBodySchema,
  listPurchaseDocumentsQuerySchema,
  purchaseDocumentIdParamSchema,
  purchaseLineIdParamSchema,
  updatePurchaseDocumentBodySchema,
  updatePurchaseLineBodySchema,
} from '../modules/purchases/purchase-document.schema';
import {
  createPurchaseFaBodySchema,
  listPurchaseFaQuerySchema,
  purchaseFaBatchIdParamSchema,
  updatePurchaseFaBodySchema,
} from '../modules/purchases/purchase-fa.schema';
import {
  loanStatementQuerySchema,
  partyStatementQuerySchema,
  reportBaseQuerySchema,
  reportDateQuerySchema,
  reportExtendedQuerySchema,
} from '../modules/reports/reports.schema';
import {
  brandSwapBodySchema,
  convertSalesDocumentBodySchema,
  createPosSessionBodySchema,
  createSalesDocumentBodySchema,
  createSalesLineBodySchema,
  finalizeSalesDocumentBodySchema,
  listPosSessionsQuerySchema,
  listSalesDocumentsQuerySchema,
  posSessionIdParamSchema,
  salesDocumentIdParamSchema,
  salesLineIdParamSchema,
  updateDocumentSequenceBodySchema,
  updatePosSessionBodySchema,
  updateSalesDocumentBodySchema,
  updateSalesLineBodySchema,
} from '../modules/sales/sales-document.schema';
import {
  authExamples,
  businessExamples,
  expenseExamples,
  inventoryExamples,
  jobWorkExamples,
  partyExamples,
  paymentExamples,
  purchaseExamples,
  responseExamples,
  salesExamples,
} from './examples';
import { genericObjectSchema, zodSchema } from './helpers';
import { Schema } from './schema-names';

type SchemaEntry = [string, Record<string, unknown>];

function withExample(
  schema: Record<string, unknown>,
  example: unknown,
): Record<string, unknown> {
  return { ...schema, example };
}

function registerZodSchemas(): SchemaEntry[] {
  const pairs: Array<[string, Parameters<typeof zodSchema>[0], unknown?]> = [
    [Schema.LoginRequest, loginBodySchema, authExamples.login.login.value],
    [
      Schema.RefreshSessionRequest,
      refreshBodySchema,
      authExamples.refresh.refresh.value,
    ],
    [Schema.LogoutRequest, logoutBodySchema, authExamples.logout.logout.value],
    [
      Schema.CreateBusinessRequest,
      createBusinessBodySchema,
      businessExamples.createBusiness.retailShop.value,
    ],
    [
      Schema.UpdateBusinessProfileRequest,
      updateBusinessProfileBodySchema,
      businessExamples.updateProfile.updateGst.value,
    ],
    [Schema.DashboardQuery, dashboardQuerySchema],
    [Schema.ListPartiesQuery, listPartiesQuerySchema],
    [
      Schema.CreatePartyRequest,
      createPartyBodySchema,
      partyExamples.createCustomer.customer.value,
    ],
    [Schema.UpdatePartyRequest, updatePartyBodySchema],
    [Schema.ListCategoriesQuery, listCategoriesQuerySchema],
    [Schema.CreateCategoryRequest, createCategoryBodySchema],
    [Schema.UpdateCategoryRequest, updateCategoryBodySchema],
    [Schema.ListBrandsQuery, listBrandsQuerySchema],
    [Schema.CreateBrandRequest, createBrandBodySchema],
    [Schema.UpdateBrandRequest, updateBrandBodySchema],
    [Schema.ListUnitsQuery, listUnitsQuerySchema],
    [Schema.CreateUnitRequest, createUnitBodySchema],
    [Schema.UpdateUnitRequest, updateUnitBodySchema],
    [Schema.ListUnitConversionsQuery, listUnitConversionsQuerySchema],
    [Schema.CreateUnitConversionRequest, createUnitConversionBodySchema],
    [Schema.UpdateUnitConversionRequest, updateUnitConversionBodySchema],
    [Schema.ListGodownsQuery, listGodownsQuerySchema],
    [Schema.CreateGodownRequest, createGodownBodySchema],
    [Schema.UpdateGodownRequest, updateGodownBodySchema],
    [Schema.ListItemsQuery, listItemsQuerySchema],
    [
      Schema.CreateItemRequest,
      createItemBodySchema,
      inventoryExamples.createItem.product.value,
    ],
    [Schema.UpdateItemRequest, updateItemBodySchema],
    [Schema.ItemIdParams, itemIdParamSchema],
    [Schema.CreateItemImageRequest, createItemImageBodySchema],
    [Schema.ItemImageParams, itemImageParamSchema],
    [Schema.UpdateItemImageRequest, updateItemImageBodySchema],
    [Schema.SetItemTierPricesRequest, putItemTierPricesBodySchema],
    [Schema.ItemTierParams, itemTierParamSchema],
    [Schema.ListItemPriceHistoryQuery, listItemPriceHistoryQuerySchema],
    [Schema.ListItemLocationsQuery, listItemLocationsQuerySchema],
    [Schema.CreateItemLocationRequest, createItemLocationBodySchema],
    [Schema.UpdateItemLocationRequest, updateItemLocationBodySchema],
    [Schema.ListStockLevelsQuery, listStockLevelsQuerySchema],
    [Schema.ListMovementsQuery, listMovementsQuerySchema],
    [
      Schema.CreateMovementRequest,
      createMovementBodySchema,
      inventoryExamples.createMovement.stockIn.value,
    ],
    [Schema.ListPriceHistoryQuery, listPriceHistoryQuerySchema],
    [Schema.ListSalesDocumentsQuery, listSalesDocumentsQuerySchema],
    [
      Schema.CreateSalesDocumentRequest,
      createSalesDocumentBodySchema,
      salesExamples.createTaxInvoice.taxInvoice.value,
    ],
    [Schema.UpdateSalesDocumentRequest, updateSalesDocumentBodySchema],
    [Schema.SalesDocumentIdParams, salesDocumentIdParamSchema],
    [Schema.SalesLineIdParams, salesLineIdParamSchema],
    [
      Schema.CreateSalesLineRequest,
      createSalesLineBodySchema,
      salesExamples.addLine.productLine.value,
    ],
    [Schema.UpdateSalesLineRequest, updateSalesLineBodySchema],
    [
      Schema.ConvertSalesDocumentRequest,
      convertSalesDocumentBodySchema,
      salesExamples.convert.toInvoice.value,
    ],
    [Schema.BrandSwapRequest, brandSwapBodySchema],
    [
      Schema.FinalizeSalesDocumentRequest,
      finalizeSalesDocumentBodySchema,
      salesExamples.finalize.finalize.value,
    ],
    [Schema.ListPosSessionsQuery, listPosSessionsQuerySchema],
    [Schema.CreatePosSessionRequest, createPosSessionBodySchema],
    [Schema.UpdatePosSessionRequest, updatePosSessionBodySchema],
    [Schema.PosSessionIdParams, posSessionIdParamSchema],
    [Schema.UpdateDocumentSequenceRequest, updateDocumentSequenceBodySchema],
    [Schema.ListPurchaseDocumentsQuery, listPurchaseDocumentsQuerySchema],
    [
      Schema.CreatePurchaseDocumentRequest,
      createPurchaseDocumentBodySchema,
      purchaseExamples.createPurchaseBill.purchaseBill.value,
    ],
    [Schema.UpdatePurchaseDocumentRequest, updatePurchaseDocumentBodySchema],
    [Schema.PurchaseDocumentIdParams, purchaseDocumentIdParamSchema],
    [Schema.PurchaseLineIdParams, purchaseLineIdParamSchema],
    [
      Schema.CreatePurchaseLineRequest,
      createPurchaseLineBodySchema,
      purchaseExamples.addLine.productLine.value,
    ],
    [Schema.UpdatePurchaseLineRequest, updatePurchaseLineBodySchema],
    [Schema.ConvertPurchaseDocumentRequest, convertPurchaseDocumentBodySchema],
    [
      Schema.FinalizePurchaseDocumentRequest,
      finalizePurchaseDocumentBodySchema,
    ],
    [Schema.ListExpensesQuery, listExpensesQuerySchema],
    [
      Schema.CreateExpenseRequest,
      createExpenseBodySchema,
      expenseExamples.createExpense.officeRent.value,
    ],
    [Schema.UpdateExpenseRequest, updateExpenseBodySchema],
    [Schema.ListExpenseCategoriesQuery, listExpenseCategoriesQuerySchema],
    [Schema.CreateExpenseCategoryRequest, createExpenseCategoryBodySchema],
    [Schema.UpdateExpenseCategoryRequest, updateExpenseCategoryBodySchema],
    [Schema.ListFixedAssetPurchasesQuery, listPurchaseFaQuerySchema],
    [Schema.CreateFixedAssetPurchaseRequest, createPurchaseFaBodySchema],
    [Schema.UpdateFixedAssetPurchaseRequest, updatePurchaseFaBodySchema],
    [Schema.FixedAssetPurchaseBatchParams, purchaseFaBatchIdParamSchema],
    [Schema.ListPaymentsQuery, listPaymentsQuerySchema],
    [
      Schema.CreatePaymentRequest,
      createPaymentBodySchema,
      paymentExamples.receivePayment.received.value,
    ],
    [Schema.UpdatePaymentRequest, updatePaymentBodySchema],
    [Schema.PaymentIdParams, paymentIdParamSchema],
    [Schema.CreatePaymentAllocationRequest, createAllocationBodySchema],
    [Schema.PaymentAllocationParams, allocationIdParamSchema],
    [Schema.ListJobWorkOrdersQuery, listJobWorkOrdersQuerySchema],
    [
      Schema.CreateJobWorkOrderRequest,
      createJobWorkOrderBodySchema,
      jobWorkExamples.createOrder.order.value,
    ],
    [Schema.UpdateJobWorkOrderRequest, updateJobWorkOrderBodySchema],
    [Schema.ReportBaseQuery, reportBaseQuerySchema],
    [Schema.ReportExtendedQuery, reportExtendedQuerySchema],
    [Schema.ReportDateQuery, reportDateQuerySchema],
    [Schema.PartyStatementQuery, partyStatementQuerySchema],
    [Schema.LoanStatementQuery, loanStatementQuerySchema],
    [Schema.CreateInvitationRequest, createInvitationBodySchema],
    [Schema.InvitationTokenParams, invitationTokenParamsSchema],
    [Schema.InvitationIdParams, invitationIdParamsSchema],
    [Schema.CompanyMemberIdParams, companyMemberIdParamsSchema],
    [Schema.UpdateCompanyMemberRequest, updateCompanyMemberBodySchema],
  ];

  return pairs.map(([name, schema, example]) => {
    const json = zodSchema(schema, name);
    return [name, example !== undefined ? withExample(json, example) : json];
  });
}

function entitySchemas(): SchemaEntry[] {
  const categoryLike = {
    type: 'object',
    properties: {
      id: {
        type: 'string',
        format: 'uuid',
        example: '550e8400-e29b-41d4-a716-446655440001',
      },
      name: { type: 'string', example: 'Groceries' },
      item_count: { type: 'integer', example: 42 },
      created_at: {
        type: 'string',
        format: 'date-time',
        example: '2024-04-01T10:00:00.000Z',
      },
      updated_at: {
        type: 'string',
        format: 'date-time',
        example: '2024-04-01T10:00:00.000Z',
      },
    },
    example: responseExamples.category,
  };

  return [
    [
      Schema.HealthResponse,
      {
        type: 'object',
        properties: {
          status: { type: 'string', example: 'ok' },
          name: { type: 'string', example: 'Billing Baba API' },
          version: { type: 'string', example: '1.0.0' },
          environment: { type: 'string', example: 'development' },
          uptime: { type: 'integer', example: 3600 },
          timestamp: {
            type: 'string',
            format: 'date-time',
            example: '2024-04-01T10:00:00.000Z',
          },
        },
        example: responseExamples.health,
      },
    ],
    [
      Schema.DatabaseHealthResponse,
      {
        type: 'object',
        properties: {
          database: {
            type: 'string',
            enum: ['connected', 'disconnected', 'not_configured'],
            example: 'connected',
          },
        },
        example: { database: 'connected' },
      },
    ],
    [Schema.CategoryResponse, categoryLike],
    [Schema.BrandResponse, { ...categoryLike }],
    [
      Schema.UnitResponse,
      {
        type: 'object',
        additionalProperties: true,
        example: {
          id: '550e8400-e29b-41d4-a716-446655440001',
          name: 'Pieces',
          short_name: 'PCS',
        },
      },
    ],
    [Schema.UnitConversionResponse, genericObjectSchema],
    [Schema.GodownResponse, genericObjectSchema],
    [
      Schema.PartyResponse,
      { ...genericObjectSchema, example: responseExamples.party },
    ],
    [Schema.ItemResponse, genericObjectSchema],
    [Schema.ItemImageResponse, genericObjectSchema],
    [Schema.ItemLocationResponse, genericObjectSchema],
    [Schema.StockLevelResponse, genericObjectSchema],
    [Schema.MovementResponse, genericObjectSchema],
    [Schema.PriceHistoryResponse, genericObjectSchema],
    [
      Schema.AuthSessionResponse,
      { ...genericObjectSchema, example: responseExamples.authSession },
    ],
    [Schema.MeResponse, genericObjectSchema],
    [Schema.BusinessResponse, genericObjectSchema],
    [Schema.BusinessProfileResponse, genericObjectSchema],
    [Schema.SalesDocumentResponse, genericObjectSchema],
    [Schema.SalesLineResponse, genericObjectSchema],
    [Schema.PosSessionResponse, genericObjectSchema],
    [Schema.DocumentSequenceResponse, genericObjectSchema],
    [Schema.PurchaseDocumentResponse, genericObjectSchema],
    [Schema.PurchaseLineResponse, genericObjectSchema],
    [Schema.ExpenseResponse, genericObjectSchema],
    [Schema.ExpenseCategoryResponse, genericObjectSchema],
    [Schema.FixedAssetPurchaseResponse, genericObjectSchema],
    [Schema.PaymentResponse, genericObjectSchema],
    [Schema.PaymentAllocationResponse, genericObjectSchema],
    [Schema.JobWorkOrderResponse, genericObjectSchema],
    [Schema.DashboardResponse, genericObjectSchema],
    [Schema.ReportDataResponse, genericObjectSchema],
    [Schema.ReportPaginatedResponse, genericObjectSchema],
  ];
}

export function buildSchemas(): Record<string, Record<string, unknown>> {
  return Object.fromEntries([
    ...registerZodSchemas(),
    ...entitySchemas(),
    [Schema.InvitationResponse, genericObjectSchema],
    [Schema.InvitationPublicResponse, genericObjectSchema],
    [Schema.AcceptInvitationResponse, genericObjectSchema],
    [Schema.SharedCompanyResponse, genericObjectSchema],
    [Schema.PendingInvitationResponse, genericObjectSchema],
    [Schema.CompanyMemberResponse, genericObjectSchema],
  ]);
}
