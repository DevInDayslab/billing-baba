import type { SupportedSyncCommandName } from '../../modules/sync/apply/commands/command-registry';
import { isSupportedSyncCommand } from '../../modules/sync/apply/commands/command-registry';
import type { BusinessAccessContext } from './collaboration-permission.types';
import { canPermission } from './role-permission-registry';
import {
  actionForRowOperation,
  moduleForEntityType,
  permissionForCommand,
} from './sync-entity-permissions';

export function canSyncRowMutation(
  access: BusinessAccessContext,
  entityType: string,
  operation: 'create' | 'update' | 'delete',
): boolean {
  const module = moduleForEntityType(entityType);
  if (!module) {
    return access.kind === 'full';
  }

  return canPermission(access, module, actionForRowOperation(operation));
}

export function canSyncCommand(
  access: BusinessAccessContext,
  command: string,
): boolean {
  if (!isSupportedSyncCommand(command)) {
    return access.kind === 'full';
  }

  const { module, action } = permissionForCommand(
    command as SupportedSyncCommandName,
  );
  return canPermission(access, module, action);
}

export function canSyncPullEntity(
  access: BusinessAccessContext,
  entityType: string,
): boolean {
  const module = moduleForEntityType(entityType);
  if (!module) {
    return access.kind === 'full';
  }

  return canPermission(access, module, 'view');
}
