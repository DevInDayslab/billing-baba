import type { UserRole } from '../../modules/auth/auth.types';

/** Owner and manager may view or recover hidden ledger data per docs/05-api.md */
export function canViewHiddenLedger(role?: UserRole): boolean {
  return role === 'owner' || role === 'manager';
}
