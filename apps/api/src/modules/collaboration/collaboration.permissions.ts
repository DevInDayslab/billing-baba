import { AppError } from '../../shared/errors/app-error';
import type { CollaborationRole } from './collaboration.types';

export type CollaborationAction =
  | 'members:read'
  | 'members:update'
  | 'members:delete'
  | 'invitations:create'
  | 'invitations:cancel'
  | 'invitations:reinvite'
  | 'invitations:read';

const OWNER_ONLY_ACTIONS = new Set<CollaborationAction>([
  'members:read',
  'members:update',
  'members:delete',
  'invitations:create',
  'invitations:cancel',
  'invitations:reinvite',
  'invitations:read',
]);

export function assertCollaborationAction(
  isOwner: boolean,
  action: CollaborationAction,
  collaboratorRole?: CollaborationRole | null,
): void {
  if (isOwner) return;

  if (OWNER_ONLY_ACTIONS.has(action)) {
    throw new AppError(
      'FORBIDDEN',
      'Only the business owner can manage company members and invitations',
      403,
    );
  }

  if (collaboratorRole == null) {
    throw new AppError(
      'FORBIDDEN',
      'You do not have access to this company',
      403,
    );
  }

  throw new AppError('FORBIDDEN', 'Your role does not allow this action', 403);
}
