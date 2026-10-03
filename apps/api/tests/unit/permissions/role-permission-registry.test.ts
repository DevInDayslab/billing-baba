import { describe, expect, test } from 'bun:test';
import type { CollaborationRole } from '../../../src/modules/collaboration/collaboration.types';
import {
  canPermission,
  permissionLevel,
} from '../../../src/shared/permissions/role-permission-registry';

describe('role permission registry', () => {
  test('owner-equivalent full access allows everything', () => {
    expect(canPermission({ kind: 'full' }, 'sync_settings', 'view')).toBe(true);
    expect(canPermission({ kind: 'full' }, 'purchase', 'create')).toBe(true);
  });

  test('biller can create sales but not purchases', () => {
    const access = {
      kind: 'collaborator' as const,
      role: 'biller' as CollaborationRole,
    };
    expect(canPermission(access, 'sale', 'create')).toBe(true);
    expect(canPermission(access, 'purchase', 'view')).toBe(false);
    expect(canPermission(access, 'item', 'view')).toBe(true);
    expect(canPermission(access, 'item', 'create')).toBe(false);
  });

  test('secondary admin inherits transaction access via all_transactions', () => {
    const access = {
      kind: 'collaborator' as const,
      role: 'secondary_admin' as CollaborationRole,
    };
    expect(canPermission(access, 'sale', 'edit')).toBe(true);
    expect(permissionLevel(access, 'sync_settings', 'view')).toBe('denied');
  });

  test('stock keeper can purchase but not edit sales', () => {
    const access = {
      kind: 'collaborator' as const,
      role: 'stock_keeper' as CollaborationRole,
    };
    expect(canPermission(access, 'purchase', 'create')).toBe(true);
    expect(canPermission(access, 'sale', 'view')).toBe(false);
  });
});
