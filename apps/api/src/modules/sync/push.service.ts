import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import {
  CommandAckRepository,
  hashCommandRequest,
} from './apply/command-ack.repository';
import { CommandApplier } from './apply/commands/command-applier';
import { MutationAckRepository } from './apply/mutation-ack.repository';
import { isRegisteredRowEntity } from './apply/row-entities';
import { RowApplier } from './apply/row-applier';
import { SYNC_MAX_PUSH_MUTATIONS } from './sync.constants';
import { syncBatchTooLarge } from './sync.errors';
import type { PushBody } from './sync.schema';

export type PushProcessResult = {
  client_batch_id: string;
  server_time: string;
  accepted: unknown[];
  replayed: unknown[];
  conflicts: unknown[];
  errors: unknown[];
};

/**
 * Applies registered row mutations and supported command mutations.
 */
export class PushService {
  constructor(
    private readonly applier?: RowApplier,
    private readonly rowAcks?: MutationAckRepository,
    private readonly commandApplier?: CommandApplier,
    private readonly commandAcks?: CommandAckRepository,
  ) {}

  private getDeps(): {
    applier: RowApplier;
    rowAcks: MutationAckRepository;
    commandApplier: CommandApplier;
    commandAcks: CommandAckRepository;
  } {
    if (
      this.applier &&
      this.rowAcks &&
      this.commandApplier &&
      this.commandAcks
    ) {
      return {
        applier: this.applier,
        rowAcks: this.rowAcks,
        commandApplier: this.commandApplier,
        commandAcks: this.commandAcks,
      };
    }
    const db = getDb();
    if (!db) {
      throw new AppError('SERVER_BUSY', 'Database is not configured', 429);
    }
    return {
      applier: this.applier ?? new RowApplier(db),
      rowAcks: this.rowAcks ?? new MutationAckRepository(db),
      commandApplier: this.commandApplier ?? new CommandApplier(db),
      commandAcks: this.commandAcks ?? new CommandAckRepository(db),
    };
  }

  async process(
    businessId: string,
    body: PushBody,
    userId?: string,
  ): Promise<PushProcessResult> {
    if (body.mutations.length > SYNC_MAX_PUSH_MUTATIONS) {
      throw syncBatchTooLarge(
        `Batch exceeds max_push_mutations (${SYNC_MAX_PUSH_MUTATIONS})`,
      );
    }

    const { applier, rowAcks, commandApplier, commandAcks } = this.getDeps();
    const accepted: unknown[] = [];
    const replayed: unknown[] = [];
    const conflicts: unknown[] = [];
    const errors: unknown[] = [];

    for (const mutation of body.mutations) {
      if (mutation.kind === 'command') {
        const requestHash = hashCommandRequest(
          mutation.command,
          mutation.payload,
        );
        const priorCommand = await commandAcks.find(
          businessId,
          mutation.command_id,
        );
        if (priorCommand) {
          if (priorCommand.requestHash !== requestHash) {
            errors.push({
              mutation_id: mutation.mutation_id,
              command_id: mutation.command_id,
              code: 'IDEMPOTENCY_PAYLOAD_MISMATCH',
              message: 'command_id was reused with a different payload',
            });
            continue;
          }
          replayed.push({
            mutation_id: mutation.mutation_id,
            kind: 'command',
            command: mutation.command,
            command_id: mutation.command_id,
            idempotent_replay: true,
            result: priorCommand.resultJson.result ?? priorCommand.resultJson,
          });
          continue;
        }

        const outcome = await commandApplier.apply({
          mutationId: mutation.mutation_id,
          command: mutation.command,
          commandId: mutation.command_id,
          payload: mutation.payload,
          deviceId: body.device_id,
          businessId,
          userId,
        });

        if (outcome.status === 'accepted') {
          accepted.push(outcome.result);
        } else if (outcome.status === 'conflict') {
          conflicts.push(outcome.result);
        } else {
          errors.push(outcome.result);
        }
        continue;
      }

      const prior = await rowAcks.find(businessId, mutation.mutation_id);
      if (prior) {
        replayed.push({
          ...prior,
          idempotent_replay: true,
        });
        continue;
      }

      if (!isRegisteredRowEntity(mutation.entity_type)) {
        errors.push({
          mutation_id: mutation.mutation_id,
          code: 'NOT_IMPLEMENTED',
          message: `Row entity_type '${mutation.entity_type}' is not registered for sync`,
        });
        continue;
      }

      const outcome = await applier.apply({
        mutationId: mutation.mutation_id,
        entityType: mutation.entity_type,
        entityId: mutation.entity_id,
        operation: mutation.operation,
        baseSyncVersion: mutation.base_sync_version,
        payload: mutation.payload,
        deviceId: body.device_id,
        businessId,
      });

      if (outcome.status === 'accepted') {
        accepted.push(outcome.result);
        await rowAcks.save({
          businessId,
          mutationId: mutation.mutation_id,
          kind: 'row',
          result: outcome.result,
        });
      } else if (outcome.status === 'conflict') {
        conflicts.push(outcome.result);
      } else {
        errors.push(outcome.result);
      }
    }

    return {
      client_batch_id: body.client_batch_id,
      server_time: new Date().toISOString(),
      accepted,
      replayed,
      conflicts,
      errors,
    };
  }
}
