import { relations } from 'drizzle-orm';
import {
  brands,
  categories,
  godowns,
  inventoryMovements,
  itemImages,
  itemLocations,
  itemPriceHistory,
  items,
  itemTierPrices,
  itemUnits,
  stockLevels,
} from './tables';
import { businesses } from '../business/tables';
import { users } from '../identity/tables';

export const categoriesRelations = relations(categories, ({ many }) => ({
  items: many(items),
}));

export const brandsRelations = relations(brands, ({ many }) => ({
  items: many(items),
}));

export const itemsRelations = relations(items, ({ one, many }) => ({
  business: one(businesses, {
    fields: [items.businessId],
    references: [businesses.id],
  }),
  category: one(categories, {
    fields: [items.categoryId],
    references: [categories.id],
  }),
  brand: one(brands, {
    fields: [items.brandId],
    references: [brands.id],
  }),
  images: many(itemImages),
  units: many(itemUnits),
  tierPrices: many(itemTierPrices),
  priceHistory: many(itemPriceHistory),
  locations: many(itemLocations),
  stockLevels: many(stockLevels),
  movements: many(inventoryMovements),
}));

export const itemImagesRelations = relations(itemImages, ({ one }) => ({
  item: one(items, {
    fields: [itemImages.itemId],
    references: [items.id],
  }),
}));

export const itemUnitsRelations = relations(itemUnits, ({ one }) => ({
  item: one(items, {
    fields: [itemUnits.itemId],
    references: [items.id],
  }),
}));

export const itemTierPricesRelations = relations(itemTierPrices, ({ one }) => ({
  item: one(items, {
    fields: [itemTierPrices.itemId],
    references: [items.id],
  }),
}));

export const itemPriceHistoryRelations = relations(itemPriceHistory, ({ one }) => ({
  item: one(items, {
    fields: [itemPriceHistory.itemId],
    references: [items.id],
  }),
  changedByUser: one(users, {
    fields: [itemPriceHistory.changedBy],
    references: [users.id],
  }),
}));

export const godownsRelations = relations(godowns, ({ many }) => ({
  locations: many(itemLocations),
  stockLevels: many(stockLevels),
  movements: many(inventoryMovements),
}));

export const itemLocationsRelations = relations(itemLocations, ({ one }) => ({
  item: one(items, {
    fields: [itemLocations.itemId],
    references: [items.id],
  }),
  godown: one(godowns, {
    fields: [itemLocations.godownId],
    references: [godowns.id],
  }),
}));

export const stockLevelsRelations = relations(stockLevels, ({ one }) => ({
  item: one(items, {
    fields: [stockLevels.itemId],
    references: [items.id],
  }),
  godown: one(godowns, {
    fields: [stockLevels.godownId],
    references: [godowns.id],
  }),
}));

export const inventoryMovementsRelations = relations(inventoryMovements, ({ one }) => ({
  item: one(items, {
    fields: [inventoryMovements.itemId],
    references: [items.id],
  }),
  godown: one(godowns, {
    fields: [inventoryMovements.godownId],
    references: [godowns.id],
  }),
  createdByUser: one(users, {
    fields: [inventoryMovements.createdBy],
    references: [users.id],
  }),
}));
