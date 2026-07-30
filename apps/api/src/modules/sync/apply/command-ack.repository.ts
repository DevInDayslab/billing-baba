import { createHash } from 'node:crypto';
import { and, eq } from 'drizzle-orm';
import type { Database } from '../../../db/client';
import { syncCommandAcks } from '../../../db/schema/sync/tables';

export type CommandAckRecord = {
  command: string;
  command_id: string;
  mutation_id: string;
  kind: 'command';
  sync_version?: number;
  server_updated_at: string;
  result: Record<string, unknown>;
};

export type CommandAckRow = {
  commandId: string;
  command: string;
  requestHash: string;
  resultJson: Record<string, unknown>;
  deviceId: string | null;
  processedAt: Date;
};

export function hashCommandRequest(
  command: string,
  payload: Record<string, unknown>,
): string {
  const stable = JSON.stringify({ command, payload });
  return createHash('sha256').update(stable).digest('hex');
}

export class CommandAckRepository {
  constructor(private readonly db: Database) {}

  async find(
    businessId: string,
    commandId: string,
  ): Promise<CommandAckRow | null> {
    const [row] = await this.db
      .select()
      .from(syncCommandAcks)
      .where(
        and(
          eq(syncCommandAcks.businessId, businessId),
          eq(syncCommandAcks.commandId, commandId),
        ),
      )
      .limit(1);

    if (!row) return null;
    return {
      commandId: row.commandId,
      command: row.command,
      requestHash: row.requestHash,
      resultJson: row.resultJson as Record<string, unknown>,
      deviceId: row.deviceId,
      processedAt: row.processedAt,
    };
  }

  async save(input: {
    businessId: string;
    commandId: string;
    command: string;
    requestHash: string;
    result: Record<string, unknown>;
    deviceId?: string;
  }): Promise<void> {
    await this.db
      .insert(syncCommandAcks)
      .values({
        businessId: input.businessId,
        commandId: input.commandId,
        command: input.command,
        requestHash: input.requestHash,
        resultJson: input.result,
        deviceId: input.deviceId ?? null,
      })
      .onConflictDoNothing({
        target: [syncCommandAcks.businessId, syncCommandAcks.commandId],
      });
  }
}
