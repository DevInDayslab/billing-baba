import type { CollaborationRole } from '../../modules/collaboration/collaboration.types';
import type {
  PermissionAction,
  PermissionLevel,
  PermissionModule,
  PermissionRow,
} from './collaboration-permission.types';
import { TRANSACTION_MODULES } from './collaboration-permission.types';

const A: PermissionLevel = 'allowed';
const D: PermissionLevel = 'denied';
const N: PermissionLevel = 'not_applicable';

function levels(
  view: PermissionLevel,
  create: PermissionLevel,
  edit: PermissionLevel,
  share: PermissionLevel,
  deleteLevel: PermissionLevel,
): Record<PermissionAction, PermissionLevel> {
  return {
    view,
    create,
    edit,
    share,
    delete: deleteLevel,
  };
}

function row(
  module: PermissionModule,
  view: PermissionLevel,
  create: PermissionLevel,
  edit: PermissionLevel,
  share: PermissionLevel,
  deleteLevel: PermissionLevel,
): PermissionRow {
  return { module, levels: levels(view, create, edit, share, deleteLevel) };
}

const SECONDARY_ADMIN_ROWS: PermissionRow[] = [
  row('all_transactions', A, A, A, A, A),
  row('settings', A, N, A, N, N),
  row('sync_settings', D, D, D, N, D),
  row('reports', A, N, N, A, N),
  row('stock_transfer', A, A, N, A, A),
  row('party_smart_connect', A, A, A, N, N),
];

const SALESMAN_TX = [D, A, D, A, D] as const;

const SALESMAN_ROWS: PermissionRow[] = [
  row('sale', ...SALESMAN_TX),
  row('payment_in', ...SALESMAN_TX),
  row('sale_order', ...SALESMAN_TX),
  row('credit_note', ...SALESMAN_TX),
  row('delivery_challan', ...SALESMAN_TX),
  row('estimate', ...SALESMAN_TX),
  row('expense', ...SALESMAN_TX),
  row('proforma', ...SALESMAN_TX),
];

const BILLER_ROWS: PermissionRow[] = [
  row('sale', A, A, D, A, D),
  row('payment_in', A, A, D, A, D),
  row('sale_order', A, A, D, A, D),
  row('credit_note', A, A, D, A, D),
  row('delivery_challan', A, A, D, A, D),
  row('estimate', A, A, D, A, D),
  row('expense', D, A, D, A, D),
  row('party', A, A, A, A, D),
  row('item', A, D, D, D, D),
  row('proforma', A, A, D, A, D),
];

const BILLER_AND_SALESMAN_ROWS: PermissionRow[] = [
  row('sale', A, A, D, A, D),
  row('payment_in', A, A, D, A, D),
  row('sale_order', A, A, D, A, D),
  row('credit_note', A, A, D, A, D),
  row('delivery_challan', A, A, D, A, D),
  row('estimate', A, A, D, A, D),
  row('expense', D, A, D, A, D),
  row('party', A, A, A, A, D),
  row('item', A, A, A, A, D),
  row('proforma', A, A, D, A, D),
];

const ACCOUNTANT_ROWS: PermissionRow[] = [
  row('all_transactions', A, D, D, A, D),
  row('settings', D, D, D, D, D),
  row('sync_settings', D, D, D, D, D),
  row('reports', A, A, A, A, A),
  row('stock_transfer', A, D, N, A, D),
];

const STOCK_KEEPER_ROWS: PermissionRow[] = [
  row('purchase', A, A, D, D, D),
  row('payment_out', A, A, D, D, D),
  row('purchase_order', A, A, D, D, D),
  row('debit_note', A, A, D, D, D),
  row('stock_transfer', D, A, N, A, D),
];

const ACCOUNTANT_EDIT_ACCESS_ROWS: PermissionRow[] = [
  row('all_transactions', A, A, A, A, A),
  row('settings', A, N, A, N, N),
  row('sync_settings', D, D, D, N, D),
  row('reports', A, N, N, A, N),
  row('stock_transfer', A, A, N, A, A),
  row('party_smart_connect', D, N, D, N, N),
];

const PRESETS: Record<CollaborationRole, PermissionRow[]> = {
  secondary_admin: SECONDARY_ADMIN_ROWS,
  salesman: SALESMAN_ROWS,
  biller: BILLER_ROWS,
  biller_and_salesman: BILLER_AND_SALESMAN_ROWS,
  accountant: ACCOUNTANT_ROWS,
  accountant_edit_access: ACCOUNTANT_EDIT_ACCESS_ROWS,
  stock_keeper: STOCK_KEEPER_ROWS,
};

function findRow(
  rows: PermissionRow[],
  module: PermissionModule,
): PermissionRow | undefined {
  return rows.find((entry) => entry.module === module);
}

export function presetForRole(role: CollaborationRole): PermissionRow[] {
  return PRESETS[role];
}

export function permissionLevel(
  access: { kind: 'full' } | { kind: 'collaborator'; role: CollaborationRole },
  module: PermissionModule,
  action: PermissionAction,
): PermissionLevel {
  if (access.kind === 'full') {
    return 'allowed';
  }

  const rows = presetForRole(access.role);
  const direct = findRow(rows, module);
  if (direct) {
    return direct.levels[action] ?? 'denied';
  }

  if (TRANSACTION_MODULES.has(module)) {
    const allTransactions = findRow(rows, 'all_transactions');
    if (allTransactions) {
      return allTransactions.levels[action] ?? 'denied';
    }
  }

  return 'denied';
}

export function canPermission(
  access: { kind: 'full' } | { kind: 'collaborator'; role: CollaborationRole },
  module: PermissionModule,
  action: PermissionAction,
): boolean {
  return permissionLevel(access, module, action) === 'allowed';
}

export function presetDto(role: CollaborationRole): {
  role: CollaborationRole;
  rows: Array<{
    module: PermissionModule;
    levels: Record<PermissionAction, PermissionLevel>;
  }>;
} {
  return {
    role,
    rows: presetForRole(role).map((entry) => ({
      module: entry.module,
      levels: { ...entry.levels },
    })),
  };
}
