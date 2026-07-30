import { and, eq } from 'drizzle-orm';
import type { Database } from '../../../db/client';
import { syncMutationAcks } from '../../../db/schema/sync/tables';

export type MutationAckResult = Record<string, unknown>;

export class MutationAckRepository {
  constructor(private readonly db: Database) {}

  async find(
    businessId: string,
    mutationId: string,
  ): Promise<MutationAckResult | null> {
    const [row] = await this.db
      .select()
      .from(syncMutationAcks)
      .where(
        and(
          eq(syncMutationAcks.businessId, businessId),
          eq(syncMutationAcks.mutationId, mutationId),
        ),
      )
      .limit(1);

    if (!row) return null;
    return row.resultJson as MutationAckResult;
  }

  async save(input: {
    businessId: string;
    mutationId: string;
    kind: string;
    result: MutationAckResult;
  }): Promise<void> {
    await this.db
      .insert(syncMutationAcks)
      .values({
        businessId: input.businessId,
        mutationId: input.mutationId,
        kind: input.kind,
        resultJson: input.result,
      })
      .onConflictDoNothing({
        target: [syncMutationAcks.businessId, syncMutationAcks.mutationId],
      });
  }
}
