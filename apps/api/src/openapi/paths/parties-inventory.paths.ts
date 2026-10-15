import { listBrandsQuerySchema } from '../../modules/inventory/brand.schema';
import { listCategoriesQuerySchema } from '../../modules/inventory/category.schema';
import { listGodownsQuerySchema } from '../../modules/inventory/godown.schema';
import {
  itemImageParamSchema,
  itemTierParamSchema,
  listItemPriceHistoryQuerySchema,
  listItemsQuerySchema,
} from '../../modules/inventory/item.schema';
import { listItemLocationsQuerySchema } from '../../modules/inventory/item-location.schema';
import { listMovementsQuerySchema } from '../../modules/inventory/movement.schema';
import { listPriceHistoryQuerySchema } from '../../modules/inventory/price-history.schema';
import { listStockLevelsQuerySchema } from '../../modules/inventory/stock-level.schema';
import {
  listUnitConversionsQuerySchema,
  listUnitsQuerySchema,
} from '../../modules/inventory/unit.schema';
import { listPartiesQuerySchema } from '../../modules/parties/party.schema';
import { inventoryExamples, partyExamples } from '../examples';
import {
  jsonRequestBody,
  okPaginatedResponse,
  okResponse,
  pathParamsFromZod,
  queryParamsFromZod,
  securedOperation,
  standardErrorResponses,
} from '../helpers';
import {
  createOperation,
  crudPaths,
  getByIdOperation,
  listOperation,
  readOnlyListPaths,
} from '../operations';
import { Schema } from '../schema-names';

const idParam = {
  name: 'id',
  in: 'path' as const,
  required: true,
  schema: { type: 'string', format: 'uuid' },
  description: 'Item UUID.',
};

export function buildPartyContactImportPaths() {
  const tag = 'Parties';
  return {
    '/parties/contact-import-sessions': {
      post: securedOperation({
        tags: [tag],
        summary: 'Start phone contact import session',
        operationId: 'createPartyContactImportSession',
        responses: {
          201: {
            description: 'Import session created',
          },
          ...standardErrorResponses,
        },
      }),
    },
    '/public/party-contact-import/{token}': {
      get: {
        tags: [tag],
        summary: 'Public import session metadata',
        operationId: 'getPublicPartyContactImportSession',
        parameters: [
          {
            name: 'token',
            in: 'path',
            required: true,
            schema: { type: 'string' },
          },
        ],
        responses: {
          200: {
            description: 'Session metadata',
          },
          ...standardErrorResponses,
        },
      },
    },
  };
}

export function buildPartiesPaths() {
  return {
    ...buildPartyContactImportPaths(),
    ...crudPaths({
    basePath: '/parties',
    tag: 'Parties',
    singular: 'Party',
    plural: 'Parties',
    operationKeys: { list: 'Parties', item: 'Party' },
    querySchema: listPartiesQuerySchema,
    querySchemaName: Schema.ListPartiesQuery,
    createBodyRef: Schema.CreatePartyRequest,
    updateBodyRef: Schema.UpdatePartyRequest,
    itemRef: Schema.PartyResponse,
    createExamples: {
      ...partyExamples.createCustomer,
      ...partyExamples.createSupplier,
    },
    listDescription:
      'Lists customers and suppliers. Filter by `party_type`, search by name/mobile, sort by name or balance.',
    }),
  };
}

export function buildInventoryPaths() {
  const catalog = {
    ...crudPaths({
      basePath: '/inventory/categories',
      tag: 'Inventory',
      singular: 'Category',
      plural: 'Categories',
      operationKeys: { list: 'Categories', item: 'Category' },
      querySchema: listCategoriesQuerySchema,
      querySchemaName: Schema.ListCategoriesQuery,
      createBodyRef: Schema.CreateCategoryRequest,
      updateBodyRef: Schema.UpdateCategoryRequest,
      itemRef: Schema.CategoryResponse,
    }),
    ...crudPaths({
      basePath: '/inventory/brands',
      tag: 'Inventory',
      singular: 'Brand',
      plural: 'Brands',
      operationKeys: { list: 'Brands', item: 'Brand' },
      querySchema: listBrandsQuerySchema,
      querySchemaName: Schema.ListBrandsQuery,
      createBodyRef: Schema.CreateBrandRequest,
      updateBodyRef: Schema.UpdateBrandRequest,
      itemRef: Schema.BrandResponse,
    }),
    ...crudPaths({
      basePath: '/inventory/units',
      tag: 'Inventory',
      singular: 'Unit',
      plural: 'Units',
      operationKeys: { list: 'Units', item: 'Unit' },
      querySchema: listUnitsQuerySchema,
      querySchemaName: Schema.ListUnitsQuery,
      createBodyRef: Schema.CreateUnitRequest,
      updateBodyRef: Schema.UpdateUnitRequest,
      itemRef: Schema.UnitResponse,
    }),
    ...crudPaths({
      basePath: '/inventory/unit-conversions',
      tag: 'Inventory',
      singular: 'Unit Conversion',
      plural: 'Unit Conversions',
      operationKeys: { list: 'UnitConversions', item: 'UnitConversion' },
      querySchema: listUnitConversionsQuerySchema,
      querySchemaName: Schema.ListUnitConversionsQuery,
      createBodyRef: Schema.CreateUnitConversionRequest,
      updateBodyRef: Schema.UpdateUnitConversionRequest,
      itemRef: Schema.UnitConversionResponse,
    }),
    ...crudPaths({
      basePath: '/inventory/godowns',
      tag: 'Inventory',
      singular: 'Godown',
      plural: 'Godowns',
      operationKeys: { list: 'Godowns', item: 'Godown' },
      querySchema: listGodownsQuerySchema,
      querySchemaName: Schema.ListGodownsQuery,
      createBodyRef: Schema.CreateGodownRequest,
      updateBodyRef: Schema.UpdateGodownRequest,
      itemRef: Schema.GodownResponse,
      listDescription: 'Lists warehouses (godowns) where stock is stored.',
    }),
    ...crudPaths({
      basePath: '/inventory/item-locations',
      tag: 'Inventory',
      singular: 'Item Location',
      plural: 'Item Locations',
      operationKeys: { list: 'ItemLocations', item: 'ItemLocation' },
      querySchema: listItemLocationsQuerySchema,
      querySchemaName: Schema.ListItemLocationsQuery,
      createBodyRef: Schema.CreateItemLocationRequest,
      updateBodyRef: Schema.UpdateItemLocationRequest,
      itemRef: Schema.ItemLocationResponse,
    }),
  };

  const itemsCrud = crudPaths({
    basePath: '/inventory/items',
    tag: 'Inventory',
    singular: 'Item',
    plural: 'Items',
    operationKeys: { list: 'Items', item: 'Item' },
    querySchema: listItemsQuerySchema,
    querySchemaName: Schema.ListItemsQuery,
    createBodyRef: Schema.CreateItemRequest,
    updateBodyRef: Schema.UpdateItemRequest,
    itemRef: Schema.ItemResponse,
    createExamples: inventoryExamples.createItem,
    listDescription:
      'Lists products and services. Filter by category, brand, type, stock tracking, and search.',
  });

  const itemSubResources = {
    '/inventory/items/{id}/images': {
      get: securedOperation({
        tags: ['Inventory'],
        summary: 'List Item Images',
        description: 'Returns all images attached to an inventory item.',
        operationId: 'listItemImages',
        parameters: [idParam],
        responses: {
          200: okPaginatedResponse('Item images', Schema.ItemImageResponse),
          ...standardErrorResponses,
        },
      }),
      post: securedOperation({
        tags: ['Inventory'],
        summary: 'Add Item Image',
        description: 'Attaches an image URL to an inventory item.',
        operationId: 'addItemImage',
        parameters: [idParam],
        requestBody: jsonRequestBody(Schema.CreateItemImageRequest),
        responses: {
          201: okResponse('Image added', Schema.ItemImageResponse),
          ...standardErrorResponses,
        },
      }),
    },
    '/inventory/items/{id}/images/{imageId}': {
      patch: securedOperation({
        tags: ['Inventory'],
        summary: 'Update Item Image',
        description: 'Updates image metadata (sort order, alt text).',
        operationId: 'updateItemImage',
        parameters: pathParamsFromZod(
          itemImageParamSchema,
          Schema.ItemImageParams,
        ),
        requestBody: jsonRequestBody(Schema.UpdateItemImageRequest),
        responses: {
          200: okResponse('Image updated', Schema.ItemImageResponse),
          ...standardErrorResponses,
        },
      }),
      delete: securedOperation({
        tags: ['Inventory'],
        summary: 'Delete Item Image',
        description: 'Removes an image from an inventory item.',
        operationId: 'deleteItemImage',
        parameters: pathParamsFromZod(
          itemImageParamSchema,
          Schema.ItemImageParams,
        ),
        responses: {
          204: { description: 'Image removed' },
          ...standardErrorResponses,
        },
      }),
    },
    '/inventory/items/{id}/tier-prices': {
      get: securedOperation({
        tags: ['Pricing'],
        summary: 'Get Item Tier Prices',
        description:
          'Returns retail/wholesale/dealer/distributor sale prices for an item (tier_1–tier_4). Used for party pricing tiers.',
        operationId: 'getItemTierPrices',
        parameters: [idParam],
        responses: {
          200: okResponse('Tier prices', Schema.ItemResponse),
          ...standardErrorResponses,
        },
      }),
      put: securedOperation({
        tags: ['Pricing'],
        summary: 'Set Item Tier Prices',
        description: 'Replaces all tier prices for an item.',
        operationId: 'setItemTierPrices',
        parameters: [idParam],
        requestBody: jsonRequestBody(Schema.SetItemTierPricesRequest),
        responses: {
          200: okResponse('Tier prices updated', Schema.ItemResponse),
          ...standardErrorResponses,
        },
      }),
    },
    '/inventory/items/{id}/tier-prices/{tier}': {
      delete: securedOperation({
        tags: ['Pricing'],
        summary: 'Delete Item Tier Price',
        description: 'Removes a specific pricing tier override.',
        operationId: 'deleteItemTierPrice',
        parameters: pathParamsFromZod(
          itemTierParamSchema,
          Schema.ItemTierParams,
        ),
        responses: {
          204: { description: 'Tier price removed' },
          ...standardErrorResponses,
        },
      }),
    },
    '/inventory/items/{id}/price-history': {
      get: securedOperation({
        tags: ['Inventory'],
        summary: 'Get Item Price History',
        description:
          'Returns the append-only price change log for a specific item.',
        operationId: 'getItemPriceHistory',
        parameters: [
          idParam,
          ...queryParamsFromZod(
            listItemPriceHistoryQuerySchema,
            Schema.ListItemPriceHistoryQuery,
          ),
        ],
        responses: {
          200: okPaginatedResponse(
            'Price history',
            Schema.PriceHistoryResponse,
          ),
          ...standardErrorResponses,
        },
      }),
    },
    '/inventory/items/{itemId}/suppliers': {
      get: securedOperation({
        tags: ['Inventory'],
        summary: 'List Item Suppliers',
        description:
          'Returns supplier party links for an item. Exactly one may be default when the list is non-empty.',
        operationId: 'listItemSuppliers',
        parameters: [idParam],
        responses: {
          200: { description: 'Item suppliers' },
          ...standardErrorResponses,
        },
      }),
      put: securedOperation({
        tags: ['Inventory'],
        summary: 'Replace Item Suppliers',
        description:
          'Replaces the supplier set for an item. Requires exactly one default when suppliers are present.',
        operationId: 'replaceItemSuppliers',
        parameters: [idParam],
        responses: {
          200: { description: 'Suppliers replaced' },
          ...standardErrorResponses,
        },
      }),
    },
    '/inventory/items/{itemId}/bom': {
      get: securedOperation({
        tags: ['Inventory'],
        summary: 'Get Item BOM',
        description:
          'Returns manufacturing bill of materials and additional costs for a finished good.',
        operationId: 'getItemBom',
        parameters: [idParam],
        responses: {
          200: { description: 'Item BOM' },
          ...standardErrorResponses,
        },
      }),
      put: securedOperation({
        tags: ['Inventory'],
        summary: 'Replace Item BOM',
        description:
          'Replaces BOM materials and costs. Quantities must be positive; circular BOMs are rejected.',
        operationId: 'replaceItemBom',
        parameters: [idParam],
        responses: {
          200: { description: 'BOM replaced' },
          ...standardErrorResponses,
        },
      }),
    },
  };

  const stock = {
    ...readOnlyListPaths({
      basePath: '/inventory/stock-levels',
      tag: 'Inventory',
      singular: 'Stock Level',
      plural: 'Stock Levels',
      operationKeys: { list: 'StockLevels', item: 'StockLevel' },
      querySchema: listStockLevelsQuerySchema,
      querySchemaName: Schema.ListStockLevelsQuery,
      itemRef: Schema.StockLevelResponse,
      description:
        'Read-only stock quantities per item and godown. Updated by movements and document finalization.',
    }),
    '/inventory/movements': {
      get: listOperation({
        tag: 'Inventory',
        summary: 'List Inventory Movements',
        description:
          'Immutable stock movement ledger. Movements cannot be edited or deleted.',
        operationId: 'listInventoryMovements',
        querySchema: listMovementsQuerySchema,
        querySchemaName: Schema.ListMovementsQuery,
        itemRef: Schema.MovementResponse,
      }),
      post: createOperation({
        tag: 'Inventory',
        summary: 'Record Inventory Movement',
        description:
          'Records a manual stock adjustment (opening, transfer, damage, etc.). Finalized documents create movements automatically.',
        operationId: 'createInventoryMovement',
        bodyRef: Schema.CreateMovementRequest,
        itemRef: Schema.MovementResponse,
        examples: inventoryExamples.createMovement,
      }),
    },
    '/inventory/movements/{id}': {
      get: getByIdOperation({
        tag: 'Inventory',
        summary: 'Get Inventory Movement',
        description: 'Returns a single stock movement record.',
        operationId: 'getInventoryMovement',
        itemRef: Schema.MovementResponse,
      }),
    },
    ...readOnlyListPaths({
      basePath: '/inventory/price-history',
      tag: 'Inventory',
      singular: 'Price History Record',
      plural: 'Price History',
      operationKeys: { list: 'PriceHistory', item: 'PriceHistoryRecord' },
      querySchema: listPriceHistoryQuerySchema,
      querySchemaName: Schema.ListPriceHistoryQuery,
      itemRef: Schema.PriceHistoryResponse,
      description: 'Business-wide append-only item price change log.',
    }),
  };

  return { ...catalog, ...itemsCrud, ...itemSubResources, ...stock };
}
