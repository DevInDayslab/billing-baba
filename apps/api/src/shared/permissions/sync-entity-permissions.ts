import type { SupportedSyncCommandName } from '../../modules/sync/apply/commands/command-registry';
import type {
  PermissionAction,
  PermissionModule,
} from './collaboration-permission.types';

const ENTITY_MODULE_MAP: Record<string, PermissionModule> = {
  categories: 'item',
  items: 'item',
  unit_definitions: 'item',
  brands: 'item',
  godowns: 'item',
  item_suppliers: 'item',
  item_bom_materials: 'item',
  item_bom_costs: 'item',
  item_alternatives: 'item',
  item_tier_prices: 'item',
  parties: 'party',
  sales_documents: 'sale',
  sales_document_lines: 'sale',
  purchase_documents: 'purchase',
  purchase_document_lines: 'purchase',
  expenses: 'expense',
  expense_categories: 'expense',
  expense_items: 'expense',
  business_settings: 'settings',
  tax_rates: 'settings',
  leads: 'party_smart_connect',
  lead_activities: 'party_smart_connect',
  contacts: 'party_smart_connect',
  contact_activities: 'party_smart_connect',
  deals: 'party_smart_connect',
  todos: 'settings',
  stock_levels: 'stock_transfer',
};

const COMMAND_MODULE_ACTION: Record<
  SupportedSyncCommandName,
  { module: PermissionModule; action: PermissionAction }
> = {
  finalize_sale: { module: 'sale', action: 'create' },
  finalize_purchase: { module: 'purchase', action: 'create' },
  finalize_credit_note: { module: 'credit_note', action: 'create' },
  finalize_debit_note: { module: 'debit_note', action: 'create' },
  stock_adjustment: { module: 'stock_transfer', action: 'create' },
  delete_transaction: { module: 'settings', action: 'delete' },
  restore_transaction: { module: 'settings', action: 'edit' },
};

const ROW_OPERATION_ACTION: Record<
  'create' | 'update' | 'delete',
  PermissionAction
> = {
  create: 'create',
  update: 'edit',
  delete: 'delete',
};

export function moduleForEntityType(
  entityType: string,
): PermissionModule | null {
  return ENTITY_MODULE_MAP[entityType] ?? null;
}

export function actionForRowOperation(
  operation: 'create' | 'update' | 'delete',
): PermissionAction {
  return ROW_OPERATION_ACTION[operation];
}

export function permissionForCommand(command: SupportedSyncCommandName): {
  module: PermissionModule;
  action: PermissionAction;
} {
  return COMMAND_MODULE_ACTION[command];
}

export function listViewableEntityTypes(
  canView: (module: PermissionModule) => boolean,
): string[] | undefined {
  const allowed = Object.entries(ENTITY_MODULE_MAP)
    .filter(([, module]) => canView(module))
    .map(([entityType]) => entityType);

  if (allowed.length === Object.keys(ENTITY_MODULE_MAP).length) {
    return undefined;
  }

  return allowed;
}
