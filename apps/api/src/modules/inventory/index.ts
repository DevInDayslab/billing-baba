import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { createBarcodeLookupRoutes } from './barcode-lookup.routes';
import { createBrandRoutes } from './brand.routes';
import { createCategoryRoutes } from './category.routes';
import { createGodownRoutes } from './godown.routes';
import { createItemRoutes } from './item.routes';
import { createItemLocationRoutes } from './item-location.routes';
import { createMovementRoutes } from './movement.routes';
import { createPriceHistoryRoutes } from './price-history.routes';
import { createStockLevelRoutes } from './stock-level.routes';
import { createUnitRoutes } from './unit.routes';
import { createUnitConversionRoutes } from './unit-conversion.routes';

export const inventoryModule =
  (config: AppConfig): FastifyPluginAsync =>
  async (app) => {
    await app.register(createCategoryRoutes(), { prefix: '/categories' });
    await app.register(createBrandRoutes(), { prefix: '/brands' });
    await app.register(createUnitRoutes(), { prefix: '/units' });
    await app.register(createUnitConversionRoutes(), {
      prefix: '/unit-conversions',
    });
    await app.register(createGodownRoutes(), { prefix: '/godowns' });
    await app.register(createItemRoutes(config), { prefix: '/items' });
    await app.register(createBarcodeLookupRoutes(), { prefix: '/barcode' });
    await app.register(createItemLocationRoutes(config), {
      prefix: '/item-locations',
    });
    await app.register(createStockLevelRoutes(), { prefix: '/stock-levels' });
    await app.register(createMovementRoutes(), { prefix: '/movements' });
    await app.register(createPriceHistoryRoutes(), {
      prefix: '/price-history',
    });
  };
