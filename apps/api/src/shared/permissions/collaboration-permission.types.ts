import type { CollaborationRole } from '../../modules/collaboration/collaboration.types';

export type PermissionAction = 'view' | 'create' | 'edit' | 'share' | 'delete';

export type PermissionLevel = 'allowed' | 'denied' | 'not_applicable';

export type PermissionModule =
  | 'all_transactions'
  | 'settings'
  | 'sync_settings'
  | 'reports'
  | 'stock_transfer'
  | 'party_smart_connect'
  | 'sale'
  | 'payment_in'
  | 'sale_order'
  | 'credit_note'
  | 'delivery_challan'
  | 'estimate'
  | 'expense'
  | 'party'
  | 'item'
  | 'proforma'
  | 'purchase'
  | 'payment_out'
  | 'purchase_order'
  | 'debit_note';

export type PermissionRow = {
  module: PermissionModule;
  levels: Record<PermissionAction, PermissionLevel>;
};

export type BusinessAccessContext =
  | { kind: 'full' }
  | { kind: 'collaborator'; role: CollaborationRole };

export const TRANSACTION_MODULES: ReadonlySet<PermissionModule> = new Set([
  'sale',
  'payment_in',
  'sale_order',
  'credit_note',
  'delivery_challan',
  'estimate',
  'expense',
  'proforma',
  'purchase',
  'payment_out',
  'purchase_order',
  'debit_note',
]);
