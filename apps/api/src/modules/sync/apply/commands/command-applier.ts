import type { Database } from '../../../../db/client';
import {
  CommandAckRepository,
  hashCommandRequest,
} from '../command-ack.repository';
import { getCommandHandler, isSupportedSyncCommand } from './command-registry';
import type {
  CommandApplyOutcome,
  CommandMutationInput,
} from './command.types';

export class CommandApplier {
  constructor(
    private readonly db: Database,
    private readonly acks: CommandAckRepository = new CommandAckRepository(db),
  ) {}

  async apply(input: CommandMutationInput): Promise<CommandApplyOutcome> {
    if (!isSupportedSyncCommand(input.command)) {
      return {
        status: 'error',
        result: {
          mutation_id: input.mutationId,
          code: 'UNSUPPORTED_COMMAND',
          message: `Unsupported sync command: ${input.command}`,
        },
      };
    }

    const requestHash = hashCommandRequest(input.command, input.payload);
    const prior = await this.acks.find(input.businessId, input.commandId);
    if (prior) {
      if (prior.requestHash !== requestHash) {
        return {
          status: 'error',
          result: {
            mutation_id: input.mutationId,
            code: 'IDEMPOTENCY_PAYLOAD_MISMATCH',
            message: 'command_id was reused with a different payload',
          },
        };
      }
      const stored = prior.resultJson;
      return {
        status: 'accepted',
        result: {
          mutation_id: input.mutationId,
          kind: 'command',
          command: input.command,
          command_id: input.commandId,
          sync_version:
            typeof stored.sync_version === 'number' ? stored.sync_version : 0,
          server_updated_at:
            typeof stored.server_updated_at === 'string'
              ? stored.server_updated_at
              : prior.processedAt.toISOString(),
          result:
            stored.result && typeof stored.result === 'object'
              ? (stored.result as Record<string, unknown>)
              : stored,
        },
      };
    }

    const handler = getCommandHandler(input.command);
    if (!handler) {
      return {
        status: 'error',
        result: {
          mutation_id: input.mutationId,
          code: 'UNSUPPORTED_COMMAND',
          message: `Unsupported sync command: ${input.command}`,
        },
      };
    }

    const outcome = await handler(this.db, input);
    if (outcome.status === 'accepted') {
      await this.acks.save({
        businessId: input.businessId,
        commandId: input.commandId,
        command: input.command,
        requestHash,
        result: outcome.result,
        deviceId: input.deviceId,
      });
    }

    return outcome;
  }
}
