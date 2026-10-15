import { and, eq } from 'drizzle-orm';
import type { Database } from '../../../../db/client';
import { users } from '../../../../db/schema';
import { AppError } from '../../../../shared/errors/app-error';
import { RecycleBinLifecycleService } from '../../../recycle-bin/recycle-bin-lifecycle.service';
import type {
  CommandApplyOutcome,
  CommandHandler,
  CommandMutationInput,
} from './command.types';
import { transactionLifecyclePayloadSchema } from './transaction-lifecycle.schema';

function validationError(
  input: CommandMutationInput,
  message: string,
): CommandApplyOutcome {
  return {
    status: 'error',
    result: {
      mutation_id: input.mutationId,
      code: 'VALIDATION_FAILED',
      message,
    },
  };
}

async function resolveAccountId(
  db: Database,
  businessId: string,
  userId?: string,
): Promise<string> {
  if (!userId) {
    throw new AppError('UNAUTHORIZED', 'User context required', 401);
  }
  const [row] = await db
    .select({ accountId: users.accountId })
    .from(users)
    .where(and(eq(users.id, userId), eq(users.businessId, businessId)))
    .limit(1);
  if (!row?.accountId) {
    throw new AppError('FORBIDDEN', 'User not found for business', 403);
  }
  return row.accountId;
}

export const deleteTransactionHandler: CommandHandler = async (db, input) => {
  const parsed = transactionLifecyclePayloadSchema.safeParse(input.payload);
  if (!parsed.success) {
    return validationError(
      input,
      parsed.error.issues[0]?.message ?? 'Invalid delete_transaction payload',
    );
  }

  const lifecycle = new RecycleBinLifecycleService();
  const accountId = await resolveAccountId(db, input.businessId, input.userId);

  await lifecycle.deleteEntity(parsed.data.entity_type, {
    businessId: input.businessId,
    accountId,
    userId: input.userId,
  }, parsed.data.entity_id);

  const now = new Date();
  return {
    status: 'accepted',
    result: {
      mutation_id: input.mutationId,
      kind: 'command',
      command: input.command,
      command_id: input.commandId,
      sync_version: 0,
      server_updated_at: now.toISOString(),
      result: {
        entity_type: parsed.data.entity_type,
        entity_id: parsed.data.entity_id,
        action: 'deleted',
      },
    },
  };
};
