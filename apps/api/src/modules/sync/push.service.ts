import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { MutationAckRepository } from './apply/mutation-ack.repository';
import { RowApplier } from './apply/row-applier';
import { syncEntityRegistry } from './apply/entity-registry.register';
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
 * Applies registered row mutations. Commands and unregistered entities
 * return NOT_IMPLEMENTED in errors[] — no command execution.
 */
export class PushService {
  constructor(
    private readonly applier?: RowApplier,
    private readonly acks?: MutationAckRepository,
  ) {}

  private getDeps(): {
    applier: RowApplier;
    acks: MutationAckRepository;
  } {
    if (this.applier && this.acks) {
      return { applier: this.applier, acks: this.acks };
    }
    const db = getDb();
    if (!db) {
      throw new AppError('SERVER_BUSY', 'Database is not configured', 429);
    }
    return {
      applier: this.applier ?? new RowApplier(db, syncEntityRegistry),
      acks: this.acks ?? new MutationAckRepository(db),
    };
  }

  async process(
    businessId: string,
    body: PushBody,
  ): Promise<PushProcessResult> {
    if (body.mutations.length > SYNC_MAX_PUSH_MUTATIONS) {
      throw syncBatchTooLarge(
        `Batch exceeds max_push_mutations (${SYNC_MAX_PUSH_MUTATIONS})`,
      );
    }

    const { applier, acks } = this.getDeps();
    const accepted: unknown[] = [];
    const replayed: unknown[] = [];
    const conflicts: unknown[] = [];
    const errors: unknown[] = [];

    for (const mutation of body.mutations) {
      const prior = await acks.find(businessId, mutation.mutation_id);
      if (prior) {
        replayed.push({
          ...prior,
          idempotent_replay: true,
        });
        continue;
      }

      if (mutation.kind === 'command') {
        errors.push({
          mutation_id: mutation.mutation_id,
          code: 'NOT_IMPLEMENTED',
          message: 'Command mutations are not implemented',
        });
        continue;
      }

      if (!syncEntityRegistry.isRegistered(mutation.entity_type)) {
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
        await acks.save({
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
