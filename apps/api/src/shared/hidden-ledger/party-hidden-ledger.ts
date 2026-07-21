import type { UserRole } from '../../modules/auth/auth.types';
import type { PartyRecord } from '../../modules/parties/party.types';
import { canViewHiddenLedger } from './hidden-ledger-access';

export function applyHiddenLedgerVisibility(
  party: PartyRecord,
  role?: UserRole,
): PartyRecord {
  if (canViewHiddenLedger(role)) {
    return party;
  }

  const { hidden_ledger_balance: _removed, ...rest } = party;
  return rest;
}

export function applyHiddenLedgerVisibilityList(
  parties: PartyRecord[],
  role?: UserRole,
): PartyRecord[] {
  return parties.map((party) => applyHiddenLedgerVisibility(party, role));
}
