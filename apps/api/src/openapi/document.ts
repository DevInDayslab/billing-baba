import type { AppConfig } from '../config/app_config';
import {
  loginBodySchema,
  logoutBodySchema,
  refreshBodySchema,
} from '../modules/auth/auth.schema';
import { createBusinessBodySchema } from '../modules/business/business.schema';
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
  listItemsQuerySchema,
  updateItemBodySchema,
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
  createPartyBodySchema,
  listPartiesQuerySchema,
  updatePartyBodySchema,
} from '../modules/parties/party.schema';
import {
  bearerAuth,
  dataResponseSchema,
  errorResponseSchema,
  paginatedResponseSchema,
  paginationQueryProperties,
  ref,
  securedOperation,
  standardErrorResponses,
  zodSchema,
} from './helpers';

function registerSchemas(): Record<string, Record<string, unknown>> {
  const entries: Array<[string, Record<string, unknown>]> = [
    ['LoginBody', zodSchema(loginBodySchema, 'LoginBody')],
    ['RefreshBody', zodSchema(refreshBodySchema, 'RefreshBody')],
    ['LogoutBody', zodSchema(logoutBodySchema, 'LogoutBody')],
    [
      'CreateBusinessBody',
      zodSchema(createBusinessBodySchema, 'CreateBusinessBody'),
    ],
    ['ListPartiesQuery', zodSchema(listPartiesQuerySchema, 'ListPartiesQuery')],
    ['CreatePartyBody', zodSchema(createPartyBodySchema, 'CreatePartyBody')],
    ['UpdatePartyBody', zodSchema(updatePartyBodySchema, 'UpdatePartyBody')],
    [
      'ListCategoriesQuery',
      zodSchema(listCategoriesQuerySchema, 'ListCategoriesQuery'),
    ],
    [
      'CreateCategoryBody',
      zodSchema(createCategoryBodySchema, 'CreateCategoryBody'),
    ],
    [
      'UpdateCategoryBody',
      zodSchema(updateCategoryBodySchema, 'UpdateCategoryBody'),
    ],
    ['ListBrandsQuery', zodSchema(listBrandsQuerySchema, 'ListBrandsQuery')],
    ['CreateBrandBody', zodSchema(createBrandBodySchema, 'CreateBrandBody')],
    ['UpdateBrandBody', zodSchema(updateBrandBodySchema, 'UpdateBrandBody')],
    ['ListUnitsQuery', zodSchema(listUnitsQuerySchema, 'ListUnitsQuery')],
    ['CreateUnitBody', zodSchema(createUnitBodySchema, 'CreateUnitBody')],
    ['UpdateUnitBody', zodSchema(updateUnitBodySchema, 'UpdateUnitBody')],
    [
      'ListUnitConversionsQuery',
      zodSchema(listUnitConversionsQuerySchema, 'ListUnitConversionsQuery'),
    ],
    [
      'CreateUnitConversionBody',
      zodSchema(createUnitConversionBodySchema, 'CreateUnitConversionBody'),
    ],
    [
      'UpdateUnitConversionBody',
      zodSchema(updateUnitConversionBodySchema, 'UpdateUnitConversionBody'),
    ],
    ['ListGodownsQuery', zodSchema(listGodownsQuerySchema, 'ListGodownsQuery')],
    ['CreateGodownBody', zodSchema(createGodownBodySchema, 'CreateGodownBody')],
    ['UpdateGodownBody', zodSchema(updateGodownBodySchema, 'UpdateGodownBody')],
    ['ListItemsQuery', zodSchema(listItemsQuerySchema, 'ListItemsQuery')],
    ['CreateItemBody', zodSchema(createItemBodySchema, 'CreateItemBody')],
    ['UpdateItemBody', zodSchema(updateItemBodySchema, 'UpdateItemBody')],
    [
      'ListItemLocationsQuery',
      zodSchema(listItemLocationsQuerySchema, 'ListItemLocationsQuery'),
    ],
    [
      'CreateItemLocationBody',
      zodSchema(createItemLocationBodySchema, 'CreateItemLocationBody'),
    ],
    [
      'UpdateItemLocationBody',
      zodSchema(updateItemLocationBodySchema, 'UpdateItemLocationBody'),
    ],
    [
      'ListStockLevelsQuery',
      zodSchema(listStockLevelsQuerySchema, 'ListStockLevelsQuery'),
    ],
    [
      'ListMovementsQuery',
      zodSchema(listMovementsQuerySchema, 'ListMovementsQuery'),
    ],
    [
      'CreateMovementBody',
      zodSchema(createMovementBodySchema, 'CreateMovementBody'),
    ],
    [
      'ListPriceHistoryQuery',
      zodSchema(listPriceHistoryQuerySchema, 'ListPriceHistoryQuery'),
    ],
  ];

  return Object.fromEntries(entries);
}

const idParam = {
  name: 'id',
  in: 'path',
  required: true,
  schema: { type: 'string', format: 'uuid' },
};

function listOp(
  tag: string,
  summary: string,
  description: string,
  operationId: string,
  queryRef: string,
  itemRef: string,
  extraQuery?: Record<string, unknown>,
) {
  return securedOperation({
    tags: [tag],
    summary,
    description,
    operationId,
    parameters: [
      ...Object.entries({ ...paginationQueryProperties, ...extraQuery }).map(
        ([name, schema]) => ({
          name,
          in: 'query',
          required: false,
          schema,
        }),
      ),
      ...(queryRef
        ? [
            {
              name: '_schema',
              in: 'query',
              required: false,
              schema: ref(queryRef),
              description: 'See schema for full query parameters.',
            },
          ]
        : []),
    ],
    responses: {
      200: {
        description: 'Paginated list',
        content: {
          'application/json': {
            schema: paginatedResponseSchema(ref(itemRef)),
          },
        },
      },
      ...standardErrorResponses,
    },
  });
}

function getOp(
  tag: string,
  summary: string,
  operationId: string,
  itemRef: string,
) {
  return securedOperation({
    tags: [tag],
    summary,
    operationId,
    parameters: [idParam],
    responses: {
      200: {
        description: 'Resource details',
        content: {
          'application/json': { schema: dataResponseSchema(ref(itemRef)) },
        },
      },
      ...standardErrorResponses,
    },
  });
}

function createOp(
  tag: string,
  summary: string,
  operationId: string,
  bodyRef: string,
  itemRef: string,
) {
  return securedOperation({
    tags: [tag],
    summary,
    operationId,
    requestBody: {
      required: true,
      content: { 'application/json': { schema: ref(bodyRef) } },
    },
    responses: {
      201: {
        description: 'Created',
        content: {
          'application/json': { schema: dataResponseSchema(ref(itemRef)) },
        },
      },
      ...standardErrorResponses,
    },
  });
}

function updateOp(
  tag: string,
  summary: string,
  operationId: string,
  bodyRef: string,
  itemRef: string,
) {
  return securedOperation({
    tags: [tag],
    summary,
    operationId,
    parameters: [idParam],
    requestBody: {
      required: true,
      content: { 'application/json': { schema: ref(bodyRef) } },
    },
    responses: {
      200: {
        description: 'Updated',
        content: {
          'application/json': { schema: dataResponseSchema(ref(itemRef)) },
        },
      },
      ...standardErrorResponses,
    },
  });
}

function deleteOp(tag: string, summary: string, operationId: string) {
  return securedOperation({
    tags: [tag],
    summary,
    operationId,
    parameters: [idParam],
    responses: {
      204: { description: 'Soft deleted' },
      ...standardErrorResponses,
    },
  });
}

function crudPaths(
  basePath: string,
  tag: string,
  resource: string,
  queryRef: string,
  createRef: string,
  updateRef: string,
  itemRef: string,
) {
  return {
    [basePath]: {
      get: listOp(
        tag,
        `List ${resource}`,
        `Returns a paginated list of ${resource.toLowerCase()} for the selected business.`,
        `list${resource}`,
        queryRef,
        itemRef,
      ),
      post: createOp(
        tag,
        `Create ${resource.toLowerCase()}`,
        `create${resource}`,
        createRef,
        itemRef,
      ),
    },
    [`${basePath}/{id}`]: {
      get: getOp(
        tag,
        `Get ${resource.toLowerCase()}`,
        `get${resource}`,
        itemRef,
      ),
      patch: updateOp(
        tag,
        `Update ${resource.toLowerCase()}`,
        `update${resource}`,
        updateRef,
        itemRef,
      ),
      delete: deleteOp(
        tag,
        `Delete ${resource.toLowerCase()}`,
        `delete${resource}`,
      ),
    },
  };
}

export function buildOpenApiDocument(config: AppConfig) {
  const schemas = registerSchemas();

  schemas.Category = {
    type: 'object',
    properties: {
      id: { type: 'string', format: 'uuid' },
      name: { type: 'string' },
      item_count: { type: 'integer' },
      created_at: { type: 'string', format: 'date-time' },
      updated_at: { type: 'string', format: 'date-time' },
    },
  };
  schemas.Brand = { ...schemas.Category };
  schemas.Unit = {
    type: 'object',
    properties: {
      id: { type: 'string', format: 'uuid' },
      name: { type: 'string' },
      short_name: { type: 'string' },
      symbol: { type: 'string', nullable: true },
      decimal_places: { type: 'integer' },
      is_system: { type: 'boolean' },
      is_active: { type: 'boolean' },
      conversion_count: { type: 'integer' },
      created_at: { type: 'string', format: 'date-time' },
      updated_at: { type: 'string', format: 'date-time' },
    },
  };
  schemas.Godown = {
    type: 'object',
    properties: {
      id: { type: 'string', format: 'uuid' },
      name: { type: 'string' },
      address: { type: 'string', nullable: true },
      is_default: { type: 'boolean' },
      stock_item_count: { type: 'integer' },
      created_at: { type: 'string', format: 'date-time' },
      updated_at: { type: 'string', format: 'date-time' },
    },
  };
  schemas.Party = { type: 'object', additionalProperties: true };
  schemas.Item = { type: 'object', additionalProperties: true };
  schemas.AuthSession = { type: 'object', additionalProperties: true };
  schemas.Me = { type: 'object', additionalProperties: true };
  schemas.Health = {
    type: 'object',
    properties: {
      status: { type: 'string', example: 'ok' },
      name: { type: 'string' },
      version: { type: 'string' },
      environment: { type: 'string' },
      uptime: { type: 'integer' },
      timestamp: { type: 'string', format: 'date-time' },
    },
  };

  return {
    openapi: '3.1.0',
    info: {
      title: config.appName,
      version: config.version,
      description: [
        'Billing Baba REST API — offline-first POS, billing, inventory, and business management.',
        '',
        '**Authentication:** Bearer JWT from `/auth/login` or `/auth/dev-login` (development).',
        '',
        '**Business scope:** Most endpoints require a JWT with `business_id` set to the active business.',
        '',
        '**Response envelope:** `{ data }` or `{ data, meta }` with `meta.totalPages`.',
        '',
        '**Errors:** `{ error: { code, message, details? }, requestId }`.',
      ].join('\n'),
    },
    servers: [
      { url: config.apiPrefix, description: `${config.environment} API` },
    ],
    tags: [
      { name: 'Health', description: 'Service health and readiness probes.' },
      {
        name: 'Authentication',
        description: 'Login, refresh, logout, and session.',
      },
      {
        name: 'Business',
        description: 'Business onboarding, profile, and membership.',
      },
      { name: 'Parties', description: 'Customers and suppliers.' },
      {
        name: 'Inventory',
        description: 'Products, services, stock, and catalog.',
      },
      {
        name: 'Sales',
        description: 'Sales invoices and POS (planned — not yet implemented).',
      },
      {
        name: 'Purchases',
        description: 'Purchase bills and supplier orders (planned).',
      },
      {
        name: 'Accounting',
        description: 'Ledger and journal entries (planned).',
      },
      { name: 'Settings', description: 'Business settings (planned).' },
      { name: 'Sync', description: 'Cloud sync protocol (planned).' },
      { name: 'Reports', description: 'Business reports (planned).' },
    ],
    components: {
      securitySchemes: bearerAuth,
      schemas,
    },
    paths: {
      '/health': {
        get: {
          tags: ['Health'],
          summary: 'Health check',
          operationId: 'getHealth',
          responses: {
            200: {
              description: 'Service is healthy',
              content: {
                'application/json': {
                  schema: dataResponseSchema(ref('Health')),
                },
              },
            },
          },
        },
      },
      '/health/db': {
        get: {
          tags: ['Health'],
          summary: 'Database health',
          operationId: 'getDatabaseHealth',
          responses: {
            200: { description: 'Database reachable' },
            503: { description: 'Database unreachable' },
          },
        },
      },
      '/auth/login': {
        post: {
          tags: ['Authentication'],
          summary: 'Login with MSG91 access token',
          operationId: 'login',
          requestBody: {
            required: true,
            content: { 'application/json': { schema: ref('LoginBody') } },
          },
          responses: {
            200: {
              description: 'Session issued',
              content: {
                'application/json': {
                  schema: dataResponseSchema(ref('AuthSession')),
                },
              },
            },
            400: {
              description: 'Validation error',
              content: {
                'application/json': { schema: errorResponseSchema },
              },
            },
          },
        },
      },
      '/auth/refresh': {
        post: {
          tags: ['Authentication'],
          summary: 'Refresh session',
          operationId: 'refreshSession',
          requestBody: {
            required: true,
            content: { 'application/json': { schema: ref('RefreshBody') } },
          },
          responses: {
            200: {
              description: 'Session refreshed',
              content: {
                'application/json': {
                  schema: dataResponseSchema(ref('AuthSession')),
                },
              },
            },
            ...standardErrorResponses,
          },
        },
      },
      '/auth/logout': {
        post: {
          tags: ['Authentication'],
          summary: 'Logout',
          operationId: 'logout',
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: { 'application/json': { schema: ref('LogoutBody') } },
          },
          responses: {
            200: { description: 'Logged out' },
            ...standardErrorResponses,
          },
        },
      },
      '/auth/me': {
        get: securedOperation({
          tags: ['Authentication'],
          summary: 'Current user and memberships',
          operationId: 'getMe',
          responses: {
            200: {
              description: 'Profile',
              content: {
                'application/json': { schema: dataResponseSchema(ref('Me')) },
              },
            },
            ...standardErrorResponses,
          },
        }),
      },
      ...(config.enableDevLogin
        ? {
            '/auth/dev-login': {
              post: {
                tags: ['Authentication'],
                summary: 'Development login',
                description:
                  'Available only when ENABLE_DEV_LOGIN=true. Issues a session for local development.',
                operationId: 'devLogin',
                responses: {
                  200: {
                    description: 'Session issued',
                    content: {
                      'application/json': {
                        schema: dataResponseSchema(ref('AuthSession')),
                      },
                    },
                  },
                },
              },
            },
          }
        : {}),
      '/businesses': {
        get: securedOperation({
          tags: ['Business'],
          summary: 'List businesses for account',
          operationId: 'listBusinesses',
          responses: {
            200: { description: 'Business list' },
            ...standardErrorResponses,
          },
        }),
        post: securedOperation({
          tags: ['Business'],
          summary: 'Create business',
          operationId: 'createBusiness',
          requestBody: {
            required: true,
            content: {
              'application/json': { schema: ref('CreateBusinessBody') },
            },
          },
          responses: {
            201: { description: 'Business created' },
            ...standardErrorResponses,
          },
        }),
      },
      '/business/profile': {
        get: securedOperation({
          tags: ['Business'],
          summary: 'Get business profile',
          operationId: 'getBusinessProfile',
          responses: {
            200: { description: 'Profile' },
            ...standardErrorResponses,
          },
        }),
        put: securedOperation({
          tags: ['Business'],
          summary: 'Update business profile',
          operationId: 'updateBusinessProfile',
          responses: {
            200: { description: 'Updated profile' },
            ...standardErrorResponses,
          },
        }),
      },
      ...crudPaths(
        '/parties',
        'Parties',
        'Party',
        'ListPartiesQuery',
        'CreatePartyBody',
        'UpdatePartyBody',
        'Party',
      ),
      ...crudPaths(
        '/inventory/categories',
        'Inventory',
        'Category',
        'ListCategoriesQuery',
        'CreateCategoryBody',
        'UpdateCategoryBody',
        'Category',
      ),
      ...crudPaths(
        '/inventory/brands',
        'Inventory',
        'Brand',
        'ListBrandsQuery',
        'CreateBrandBody',
        'UpdateBrandBody',
        'Brand',
      ),
      ...crudPaths(
        '/inventory/units',
        'Inventory',
        'Unit',
        'ListUnitsQuery',
        'CreateUnitBody',
        'UpdateUnitBody',
        'Unit',
      ),
      ...crudPaths(
        '/inventory/unit-conversions',
        'Inventory',
        'UnitConversion',
        'ListUnitConversionsQuery',
        'CreateUnitConversionBody',
        'UpdateUnitConversionBody',
        'Unit',
      ),
      ...crudPaths(
        '/inventory/godowns',
        'Inventory',
        'Godown',
        'ListGodownsQuery',
        'CreateGodownBody',
        'UpdateGodownBody',
        'Godown',
      ),
      ...crudPaths(
        '/inventory/items',
        'Inventory',
        'Item',
        'ListItemsQuery',
        'CreateItemBody',
        'UpdateItemBody',
        'Item',
      ),
      ...crudPaths(
        '/inventory/item-locations',
        'Inventory',
        'ItemLocation',
        'ListItemLocationsQuery',
        'CreateItemLocationBody',
        'UpdateItemLocationBody',
        'Item',
      ),
      '/inventory/stock-levels': {
        get: listOp(
          'Inventory',
          'List stock levels',
          'Read-only stock quantities per item and godown.',
          'listStockLevels',
          'ListStockLevelsQuery',
          'Item',
        ),
      },
      '/inventory/stock-levels/{id}': {
        get: getOp('Inventory', 'Get stock level', 'getStockLevel', 'Item'),
      },
      '/inventory/movements': {
        get: listOp(
          'Inventory',
          'List inventory movements',
          'Immutable stock movement ledger.',
          'listMovements',
          'ListMovementsQuery',
          'Item',
        ),
        post: createOp(
          'Inventory',
          'Record inventory movement',
          'createMovement',
          'CreateMovementBody',
          'Item',
        ),
      },
      '/inventory/movements/{id}': {
        get: getOp('Inventory', 'Get movement', 'getMovement', 'Item'),
      },
      '/inventory/price-history': {
        get: listOp(
          'Inventory',
          'List price history',
          'Append-only item price change log.',
          'listPriceHistory',
          'ListPriceHistoryQuery',
          'Item',
        ),
      },
      '/inventory/price-history/{id}': {
        get: getOp(
          'Inventory',
          'Get price history record',
          'getPriceHistory',
          'Item',
        ),
      },
    },
  };
}
