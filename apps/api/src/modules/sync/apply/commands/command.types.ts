import type { Database } from '../../../../db/client';

export type CommandMutationInput = {
  mutationId: string;
  command: string;
  commandId: string;
  payload: Record<string, unknown>;
  deviceId: string;
  businessId: string;
  userId?: string;
};

export type AcceptedCommandResult = {
  mutation_id: string;
  kind: 'command';
  command: string;
  command_id: string;
  sync_version: number;
  server_updated_at: string;
  result: Record<string, unknown>;
};

export type ConflictCommandResult = {
  mutation_id: string;
  command: string;
  command_id: string;
  code: string;
  message: string;
  conflict_id: string;
};

export type FailedCommandResult = {
  mutation_id: string;
  code: string;
  message: string;
  details?: Record<string, string[]>;
};

export type CommandApplyOutcome =
  | { status: 'accepted'; result: AcceptedCommandResult }
  | { status: 'conflict'; result: ConflictCommandResult }
  | { status: 'error'; result: FailedCommandResult };

export type CommandHandler = (
  db: Database,
  input: CommandMutationInput,
) => Promise<CommandApplyOutcome>;
