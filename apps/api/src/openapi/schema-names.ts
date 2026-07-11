/**
 * Canonical OpenAPI schema names — single source of truth for $ref targets.
 * Convention: *Request (body), *Query (query), *Params (path), *Response (entity).
 */
export const Schema = {
  // Auth
  LoginRequest: 'LoginRequest',
  RefreshSessionRequest: 'RefreshSessionRequest',
  LogoutRequest: 'LogoutRequest',
  AuthSessionResponse: 'AuthSessionResponse',
  MeResponse: 'MeResponse',

  // Business
  CreateBusinessRequest: 'CreateBusinessRequest',
  UpdateBusinessProfileRequest: 'UpdateBusinessProfileRequest',
  BusinessResponse: 'BusinessResponse',
  BusinessProfileResponse: 'BusinessProfileResponse',
  DashboardQuery: 'DashboardQuery',
  DashboardResponse: 'DashboardResponse',

  // Parties
  ListPartiesQuery: 'ListPartiesQuery',
  CreatePartyRequest: 'CreatePartyRequest',
  UpdatePartyRequest: 'UpdatePartyRequest',
  PartyResponse: 'PartyResponse',

  // Inventory — catalog
  ListCategoriesQuery: 'ListCategoriesQuery',
  CreateCategoryRequest: 'CreateCategoryRequest',
  UpdateCategoryRequest: 'UpdateCategoryRequest',
  CategoryResponse: 'CategoryResponse',

  ListBrandsQuery: 'ListBrandsQuery',
  CreateBrandRequest: 'CreateBrandRequest',
  UpdateBrandRequest: 'UpdateBrandRequest',
  BrandResponse: 'BrandResponse',

  ListUnitsQuery: 'ListUnitsQuery',
  CreateUnitRequest: 'CreateUnitRequest',
  UpdateUnitRequest: 'UpdateUnitRequest',
  UnitResponse: 'UnitResponse',

  ListUnitConversionsQuery: 'ListUnitConversionsQuery',
  CreateUnitConversionRequest: 'CreateUnitConversionRequest',
  UpdateUnitConversionRequest: 'UpdateUnitConversionRequest',
  UnitConversionResponse: 'UnitConversionResponse',

  ListGodownsQuery: 'ListGodownsQuery',
  CreateGodownRequest: 'CreateGodownRequest',
  UpdateGodownRequest: 'UpdateGodownRequest',
  GodownResponse: 'GodownResponse',

  ListItemLocationsQuery: 'ListItemLocationsQuery',
  CreateItemLocationRequest: 'CreateItemLocationRequest',
  UpdateItemLocationRequest: 'UpdateItemLocationRequest',
  ItemLocationResponse: 'ItemLocationResponse',

  // Inventory — items
  ListItemsQuery: 'ListItemsQuery',
  CreateItemRequest: 'CreateItemRequest',
  UpdateItemRequest: 'UpdateItemRequest',
  ItemResponse: 'ItemResponse',
  ItemIdParams: 'ItemIdParams',
  CreateItemImageRequest: 'CreateItemImageRequest',
  UpdateItemImageRequest: 'UpdateItemImageRequest',
  ItemImageParams: 'ItemImageParams',
  ItemImageResponse: 'ItemImageResponse',
  SetItemTierPricesRequest: 'SetItemTierPricesRequest',
  ItemTierParams: 'ItemTierParams',
  ListItemPriceHistoryQuery: 'ListItemPriceHistoryQuery',

  ListStockLevelsQuery: 'ListStockLevelsQuery',
  StockLevelResponse: 'StockLevelResponse',
  ListMovementsQuery: 'ListMovementsQuery',
  CreateMovementRequest: 'CreateMovementRequest',
  MovementResponse: 'MovementResponse',
  ListPriceHistoryQuery: 'ListPriceHistoryQuery',
  PriceHistoryResponse: 'PriceHistoryResponse',

  // Sales
  ListSalesDocumentsQuery: 'ListSalesDocumentsQuery',
  CreateSalesDocumentRequest: 'CreateSalesDocumentRequest',
  UpdateSalesDocumentRequest: 'UpdateSalesDocumentRequest',
  SalesDocumentResponse: 'SalesDocumentResponse',
  SalesDocumentIdParams: 'SalesDocumentIdParams',
  SalesLineIdParams: 'SalesLineIdParams',
  CreateSalesLineRequest: 'CreateSalesLineRequest',
  UpdateSalesLineRequest: 'UpdateSalesLineRequest',
  SalesLineResponse: 'SalesLineResponse',
  ConvertSalesDocumentRequest: 'ConvertSalesDocumentRequest',
  BrandSwapRequest: 'BrandSwapRequest',
  FinalizeSalesDocumentRequest: 'FinalizeSalesDocumentRequest',

  ListPosSessionsQuery: 'ListPosSessionsQuery',
  CreatePosSessionRequest: 'CreatePosSessionRequest',
  UpdatePosSessionRequest: 'UpdatePosSessionRequest',
  PosSessionResponse: 'PosSessionResponse',
  PosSessionIdParams: 'PosSessionIdParams',
  UpdateDocumentSequenceRequest: 'UpdateDocumentSequenceRequest',
  DocumentSequenceResponse: 'DocumentSequenceResponse',

  // Purchases
  ListPurchaseDocumentsQuery: 'ListPurchaseDocumentsQuery',
  CreatePurchaseDocumentRequest: 'CreatePurchaseDocumentRequest',
  UpdatePurchaseDocumentRequest: 'UpdatePurchaseDocumentRequest',
  PurchaseDocumentResponse: 'PurchaseDocumentResponse',
  PurchaseDocumentIdParams: 'PurchaseDocumentIdParams',
  PurchaseLineIdParams: 'PurchaseLineIdParams',
  CreatePurchaseLineRequest: 'CreatePurchaseLineRequest',
  UpdatePurchaseLineRequest: 'UpdatePurchaseLineRequest',
  PurchaseLineResponse: 'PurchaseLineResponse',
  ConvertPurchaseDocumentRequest: 'ConvertPurchaseDocumentRequest',
  FinalizePurchaseDocumentRequest: 'FinalizePurchaseDocumentRequest',

  ListFixedAssetPurchasesQuery: 'ListFixedAssetPurchasesQuery',
  CreateFixedAssetPurchaseRequest: 'CreateFixedAssetPurchaseRequest',
  UpdateFixedAssetPurchaseRequest: 'UpdateFixedAssetPurchaseRequest',
  FixedAssetPurchaseResponse: 'FixedAssetPurchaseResponse',
  FixedAssetPurchaseBatchParams: 'FixedAssetPurchaseBatchParams',

  // Expenses
  ListExpensesQuery: 'ListExpensesQuery',
  CreateExpenseRequest: 'CreateExpenseRequest',
  UpdateExpenseRequest: 'UpdateExpenseRequest',
  ExpenseResponse: 'ExpenseResponse',

  ListExpenseCategoriesQuery: 'ListExpenseCategoriesQuery',
  CreateExpenseCategoryRequest: 'CreateExpenseCategoryRequest',
  UpdateExpenseCategoryRequest: 'UpdateExpenseCategoryRequest',
  ExpenseCategoryResponse: 'ExpenseCategoryResponse',

  // Payments
  ListPaymentsQuery: 'ListPaymentsQuery',
  CreatePaymentRequest: 'CreatePaymentRequest',
  UpdatePaymentRequest: 'UpdatePaymentRequest',
  PaymentResponse: 'PaymentResponse',
  PaymentIdParams: 'PaymentIdParams',
  CreatePaymentAllocationRequest: 'CreatePaymentAllocationRequest',
  PaymentAllocationParams: 'PaymentAllocationParams',
  PaymentAllocationResponse: 'PaymentAllocationResponse',

  // Job work
  ListJobWorkOrdersQuery: 'ListJobWorkOrdersQuery',
  CreateJobWorkOrderRequest: 'CreateJobWorkOrderRequest',
  UpdateJobWorkOrderRequest: 'UpdateJobWorkOrderRequest',
  JobWorkOrderResponse: 'JobWorkOrderResponse',

  // Reports
  ReportBaseQuery: 'ReportBaseQuery',
  ReportExtendedQuery: 'ReportExtendedQuery',
  ReportDateQuery: 'ReportDateQuery',
  PartyStatementQuery: 'PartyStatementQuery',
  LoanStatementQuery: 'LoanStatementQuery',
  ReportDataResponse: 'ReportDataResponse',
  ReportPaginatedResponse: 'ReportPaginatedResponse',

  // Health
  HealthResponse: 'HealthResponse',
  DatabaseHealthResponse: 'DatabaseHealthResponse',
} as const;

export type ResourceOps = {
  list: { summary: string; operationId: string; description: string };
  create: { summary: string; operationId: string; description: string };
  get: { summary: string; operationId: string; description: string };
  update: { summary: string; operationId: string; description: string };
  delete: { summary: string; operationId: string; description: string };
};

/** Build consistent CRUD summaries and operationIds. */
export function crudOps(
  singular: string,
  plural: string,
  keys: { list: string; item: string },
  listDescription?: string,
): ResourceOps {
  const listDesc =
    listDescription ??
    `Returns a paginated list of ${plural.toLowerCase()} for the active business. Supports filtering, sorting, and pagination.`;
  return {
    list: {
      summary: `List ${plural}`,
      operationId: `list${keys.list}`,
      description: listDesc,
    },
    create: {
      summary: `Create ${singular}`,
      operationId: `create${keys.item}`,
      description: `Creates a new ${singular.toLowerCase()} in the active business.`,
    },
    get: {
      summary: `Get ${singular}`,
      operationId: `get${keys.item}`,
      description: `Returns a single ${singular.toLowerCase()} by ID.`,
    },
    update: {
      summary: `Update ${singular}`,
      operationId: `update${keys.item}`,
      description: `Partially updates a ${singular.toLowerCase()}. At least one field is required.`,
    },
    delete: {
      summary: `Delete ${singular}`,
      operationId: `delete${keys.item}`,
      description: `Soft-deletes a ${singular.toLowerCase()}.`,
    },
  };
}
