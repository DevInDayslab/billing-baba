import type { RecycleBinEntityType } from './recycle-bin.constants';

export type RecycleBinItemRecord = {
  entity_type: RecycleBinEntityType;
  entity_id: string;
  label: string;
  party_name: string | null;
  amount: string | null;
  transaction_date: string | null;
  deleted_at: string;
  days_remaining: number;
};
