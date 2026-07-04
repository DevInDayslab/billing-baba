import { and, eq, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { documentNumberSequences } from '../../db/schema/settings/tables';
import { AppError } from '../errors/app-error';

type DbTransaction = Parameters<Parameters<Database['transaction']>[0]>[0];

export function currentFiscalYear(date = new Date()): string {
  const year = date.getFullYear();
  const month = date.getMonth() + 1;
  if (month >= 4) {
    return `${year}-${year + 1}`;
  }
  return `${year - 1}-${year}`;
}

export async function assignDocumentNumber(
  db: Database | DbTransaction,
  businessId: string,
  documentSeries: string,
  documentDate: Date,
): Promise<string> {
  const fiscalYear = currentFiscalYear(documentDate);

  let [sequence] = await db
    .select({
      id: documentNumberSequences.id,
      prefix: documentNumberSequences.prefix,
      nextNumber: documentNumberSequences.nextNumber,
    })
    .from(documentNumberSequences)
    .where(
      and(
        eq(documentNumberSequences.businessId, businessId),
        eq(documentNumberSequences.documentSeries, documentSeries),
        eq(documentNumberSequences.fiscalYear, fiscalYear),
        eq(documentNumberSequences.isDeleted, false),
      ),
    )
    .limit(1)
    .for('update');

  if (!sequence) {
    await ensureDocumentSequence(
      db,
      businessId,
      documentSeries,
      documentSeries,
      fiscalYear,
    );
    [sequence] = await db
      .select({
        id: documentNumberSequences.id,
        prefix: documentNumberSequences.prefix,
        nextNumber: documentNumberSequences.nextNumber,
      })
      .from(documentNumberSequences)
      .where(
        and(
          eq(documentNumberSequences.businessId, businessId),
          eq(documentNumberSequences.documentSeries, documentSeries),
          eq(documentNumberSequences.fiscalYear, fiscalYear),
          eq(documentNumberSequences.isDeleted, false),
        ),
      )
      .limit(1)
      .for('update');
  }

  if (!sequence) {
    throw new AppError(
      'DOCUMENT_SEQUENCE_NOT_FOUND',
      `No number sequence found for series ${documentSeries}`,
      422,
    );
  }

  const number = sequence.nextNumber;
  const prefix = sequence.prefix ?? '';
  const documentNumber = `${prefix}${number}`;

  const [updated] = await db
    .update(documentNumberSequences)
    .set({
      nextNumber: number + 1,
      updatedAt: new Date(),
      syncVersion: sql`${documentNumberSequences.syncVersion} + 1`,
    })
    .where(eq(documentNumberSequences.id, sequence.id))
    .returning({ id: documentNumberSequences.id });

  if (!updated) {
    throw new Error('Failed to increment document number sequence');
  }

  return documentNumber;
}

export async function ensureDocumentSequence(
  db: Database | DbTransaction,
  businessId: string,
  documentSeries: string,
  prefix?: string | null,
  fiscalYear = currentFiscalYear(),
): Promise<void> {
  const [existing] = await db
    .select({ id: documentNumberSequences.id })
    .from(documentNumberSequences)
    .where(
      and(
        eq(documentNumberSequences.businessId, businessId),
        eq(documentNumberSequences.documentSeries, documentSeries),
        eq(documentNumberSequences.fiscalYear, fiscalYear),
        eq(documentNumberSequences.isDeleted, false),
      ),
    )
    .limit(1);

  if (existing) {
    return;
  }

  await db
    .insert(documentNumberSequences)
    .values({
      businessId,
      documentSeries,
      prefix: prefix ?? documentSeries,
      nextNumber: 1,
      fiscalYear,
    })
    .onConflictDoNothing();
}
