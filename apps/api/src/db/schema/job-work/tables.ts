import { integer, pgTable, text, uuid } from 'drizzle-orm/pg-core';
import { businesses } from '../business/tables';
import { money, syncedBusinessColumns, timestamptz } from '../columns';
import { parties } from '../crm/tables';
import { jobWorkOrderStatusEnum } from '../enums';
import { items } from '../inventory/tables';

const businessId = () =>
  syncedBusinessColumns.businessId.notNull().references(() => businesses.id);

/** Subcontract / job work orders with raw material consumption */
export const jobWorkOrders = pgTable('job_work_orders', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  partyId: uuid('party_id').references(() => parties.id),
  jobNumber: text('job_number'),
  status: jobWorkOrderStatusEnum('status').notNull().default('open'),
  orderDate: timestamptz('order_date').notNull().defaultNow(),
  deliveryDate: timestamptz('delivery_date'),
  finishedGoodName: text('finished_good_name').notNull(),
  finishedGoodQuantity: money('finished_good_quantity').notNull().default('1'),
  finishedGoodUnit: text('finished_good_unit').notNull().default('PCS'),
  rawMaterialsTotal: money('raw_materials_total').notNull().default('0'),
  additionalCostsTotal: money('additional_costs_total').notNull().default('0'),
  grandTotal: money('grand_total').notNull().default('0'),
  notes: text('notes'),
});

export const jobWorkRawMaterialLines = pgTable('job_work_raw_material_lines', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  jobWorkOrderId: uuid('job_work_order_id')
    .notNull()
    .references(() => jobWorkOrders.id),
  itemId: uuid('item_id')
    .notNull()
    .references(() => items.id),
  quantity: money('quantity').notNull(),
  unit: text('unit').notNull(),
  purchasePrice: money('purchase_price').notNull().default('0'),
  lineTotal: money('line_total').notNull().default('0'),
  sortOrder: integer('sort_order').notNull().default(0),
});

export const jobWorkAdditionalCosts = pgTable('job_work_additional_costs', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  jobWorkOrderId: uuid('job_work_order_id')
    .notNull()
    .references(() => jobWorkOrders.id),
  label: text('label').notNull(),
  amount: money('amount').notNull().default('0'),
  sortOrder: integer('sort_order').notNull().default(0),
});
