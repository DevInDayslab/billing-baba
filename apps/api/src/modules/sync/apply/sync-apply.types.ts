export type RowMutationInput = {
  mutationId: string;
  entityType: string;
  entityId: string;
  operation: 'create' | 'update' | 'delete';
  baseSyncVersion: number;
  payload: Record<string, unknown>;
  deviceId: string;
  businessId: string;
};

export type AcceptedRowResult = {
  mutation_id: string;
  kind: 'row';
  entity_type: string;
  entity_id: string;
  sync_version: number;
  server_updated_at: string;
};

export type ConflictRowResult = {
  mutation_id: string;
  code: string;
  entity_type: string;
  entity_id: string;
  incoming_sync_version: number;
  server_sync_version: number;
  server_payload: Record<string, unknown> | null;
  server_updated_at: string;
  suggested_resolution: string;
  conflict_id: string;
};

export type FailedRowResult = {
  mutation_id: string;
  code: string;
  message: string;
};

export type ApplyOutcome =
  | { status: 'accepted'; result: AcceptedRowResult }
  | { status: 'conflict'; result: ConflictRowResult }
  | { status: 'error'; result: FailedRowResult };
