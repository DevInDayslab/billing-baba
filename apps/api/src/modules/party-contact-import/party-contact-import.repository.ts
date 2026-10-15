import { and, asc, eq, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import {
  partyContactImportSessions,
  partyContactImportStagingRows,
} from '../../db/schema/party-contact-import/tables';
import { PartyRepository } from '../parties/party.repository';
import type {
  PartyContactImportSessionRow,
  PartyContactImportStagingRow,
  PartyContactImportStatus,
} from './party-contact-import.types';

export class PartyContactImportRepository {
  private readonly partyRepository: PartyRepository;

  constructor(private readonly db: Database) {
    this.partyRepository = new PartyRepository(db);
  }

  async hasBusinessMembership(
    businessId: string,
    accountId: string,
  ): Promise<boolean> {
    return this.partyRepository.hasBusinessMembership(businessId, accountId);
  }

  async createSession(input: {
    businessId: string;
    createdByAccountId: string;
    token: string;
    expiresAt: Date;
  }): Promise<PartyContactImportSessionRow> {
    const [row] = await this.db
      .insert(partyContactImportSessions)
      .values({
        businessId: input.businessId,
        createdByAccountId: input.createdByAccountId,
        token: input.token,
        expiresAt: input.expiresAt,
        status: 'pending',
      })
      .returning();
    if (!row) {
      throw new Error('Failed to create party contact import session');
    }
    return this.mapSession(row);
  }

  async findSessionById(
    sessionId: string,
  ): Promise<PartyContactImportSessionRow | null> {
    const [row] = await this.db
      .select()
      .from(partyContactImportSessions)
      .where(eq(partyContactImportSessions.id, sessionId))
      .limit(1);
    return row ? this.mapSession(row) : null;
  }

  async findSessionByToken(
    token: string,
  ): Promise<PartyContactImportSessionRow | null> {
    const [row] = await this.db
      .select()
      .from(partyContactImportSessions)
      .where(eq(partyContactImportSessions.token, token))
      .limit(1);
    return row ? this.mapSession(row) : null;
  }

  async updateSessionStatus(
    sessionId: string,
    status: PartyContactImportStatus,
    timestamps?: {
      openedAt?: Date;
      submittedAt?: Date;
      completedAt?: Date;
    },
  ): Promise<PartyContactImportSessionRow | null> {
    const [row] = await this.db
      .update(partyContactImportSessions)
      .set({
        status,
        openedAt: timestamps?.openedAt,
        submittedAt: timestamps?.submittedAt,
        completedAt: timestamps?.completedAt,
        updatedAt: new Date(),
      })
      .where(eq(partyContactImportSessions.id, sessionId))
      .returning();
    return row ? this.mapSession(row) : null;
  }

  async markExpiredIfNeeded(
    session: PartyContactImportSessionRow,
  ): Promise<PartyContactImportSessionRow> {
    if (
      session.status !== 'pending' &&
      session.status !== 'opened' &&
      session.status !== 'submitted'
    ) {
      return session;
    }
    if (session.expiresAt.getTime() > Date.now()) {
      return session;
    }
    const updated = await this.updateSessionStatus(session.id, 'expired');
    return updated ?? session;
  }

  async cancelSession(sessionId: string): Promise<boolean> {
    const rows = await this.db
      .update(partyContactImportSessions)
      .set({ status: 'cancelled', updatedAt: new Date() })
      .where(
        and(
          eq(partyContactImportSessions.id, sessionId),
          sql`${partyContactImportSessions.status} IN ('pending', 'opened')`,
        ),
      )
      .returning({ id: partyContactImportSessions.id });
    return rows.length > 0;
  }

  async countStagingRows(sessionId: string): Promise<number> {
    const [row] = await this.db
      .select({ count: sql<number>`count(*)::int` })
      .from(partyContactImportStagingRows)
      .where(eq(partyContactImportStagingRows.sessionId, sessionId));
    return row?.count ?? 0;
  }

  async listStagingRows(
    sessionId: string,
  ): Promise<PartyContactImportStagingRow[]> {
    const rows = await this.db
      .select()
      .from(partyContactImportStagingRows)
      .where(eq(partyContactImportStagingRows.sessionId, sessionId))
      .orderBy(asc(partyContactImportStagingRows.sortOrder));
    return rows.map((row) => this.mapStaging(row));
  }

  async replaceStagingRows(
    sessionId: string,
    rows: Array<{
      sortOrder: number;
      displayName: string;
      primaryPhone: string;
      phones: string[];
      email: string | null;
      address: string | null;
    }>,
  ): Promise<void> {
    await this.db
      .delete(partyContactImportStagingRows)
      .where(eq(partyContactImportStagingRows.sessionId, sessionId));

    if (rows.length === 0) return;

    await this.db.insert(partyContactImportStagingRows).values(
      rows.map((row) => ({
        sessionId,
        sortOrder: row.sortOrder,
        displayName: row.displayName,
        primaryPhone: row.primaryPhone,
        phones: row.phones,
        email: row.email,
        address: row.address,
      })),
    );
  }

  private mapSession(
    row: typeof partyContactImportSessions.$inferSelect,
  ): PartyContactImportSessionRow {
    return {
      id: row.id,
      businessId: row.businessId,
      createdByAccountId: row.createdByAccountId,
      token: row.token,
      status: row.status,
      expiresAt: row.expiresAt,
      openedAt: row.openedAt,
      submittedAt: row.submittedAt,
      completedAt: row.completedAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    };
  }

  private mapStaging(
    row: typeof partyContactImportStagingRows.$inferSelect,
  ): PartyContactImportStagingRow {
    return {
      id: row.id,
      sessionId: row.sessionId,
      sortOrder: row.sortOrder,
      displayName: row.displayName,
      primaryPhone: row.primaryPhone,
      phones: row.phones ?? [],
      email: row.email,
      address: row.address,
    };
  }
}
