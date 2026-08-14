import { and, eq, or } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { parties } from '../../db/schema';
import { payments } from '../../db/schema/accounting/tables';
import { expenses } from '../../db/schema/purchases/tables';
import { jobWorkOrders } from '../../db/schema/job-work/tables';
import { purchaseDocuments } from '../../db/schema/purchases/tables';
import { salesDocuments } from '../../db/schema/sales/tables';
import { AppError } from '../../shared/errors/app-error';
import type { DocumentAttachmentEntityType } from './document-attachment.constants';
import {
  paymentDirectionForEntity,
  purchaseDocumentTypesForEntity,
  salesDocumentTypesForEntity,
} from './document-attachment.constants';

export async function assertAttachmentEntityExists(
  db: Database,
  businessId: string,
  entityType: DocumentAttachmentEntityType,
  entityId: string,
): Promise<void> {
  const exists = await entityExists(db, businessId, entityType, entityId);
  if (!exists) {
    throw new AppError('NOT_FOUND', 'Transaction not found', 404);
  }
}

async function entityExists(
  db: Database,
  businessId: string,
  entityType: DocumentAttachmentEntityType,
  entityId: string,
): Promise<boolean> {
  const salesTypes = salesDocumentTypesForEntity(entityType);
  if (salesTypes) {
    const [row] = await db
      .select({ id: salesDocuments.id })
      .from(salesDocuments)
      .where(
        and(
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.id, entityId),
          eq(salesDocuments.isDeleted, false),
          salesDocumentTypeFilter(salesTypes),
        ),
      )
      .limit(1);
    return Boolean(row);
  }

  const purchaseTypes = purchaseDocumentTypesForEntity(entityType);
  if (purchaseTypes) {
    const [row] = await db
      .select({ id: purchaseDocuments.id })
      .from(purchaseDocuments)
      .where(
        and(
          eq(purchaseDocuments.businessId, businessId),
          eq(purchaseDocuments.id, entityId),
          eq(purchaseDocuments.isDeleted, false),
          purchaseDocumentTypeFilter(purchaseTypes),
        ),
      )
      .limit(1);
    return Boolean(row);
  }

  const paymentDirection = paymentDirectionForEntity(entityType);
  if (paymentDirection) {
    const [row] = await db
      .select({ id: payments.id })
      .from(payments)
      .where(
        and(
          eq(payments.businessId, businessId),
          eq(payments.id, entityId),
          eq(payments.direction, paymentDirection),
          eq(payments.isDeleted, false),
        ),
      )
      .limit(1);
    return Boolean(row);
  }

  if (entityType === 'expense') {
    const [row] = await db
      .select({ id: expenses.id })
      .from(expenses)
      .where(
        and(
          eq(expenses.businessId, businessId),
          eq(expenses.id, entityId),
          eq(expenses.isDeleted, false),
        ),
      )
      .limit(1);
    return Boolean(row);
  }

  if (entityType === 'job_work') {
    const [row] = await db
      .select({ id: jobWorkOrders.id })
      .from(jobWorkOrders)
      .where(
        and(
          eq(jobWorkOrders.businessId, businessId),
          eq(jobWorkOrders.id, entityId),
          eq(jobWorkOrders.isDeleted, false),
        ),
      )
      .limit(1);
    return Boolean(row);
  }

  if (entityType === 'party') {
    const [row] = await db
      .select({ id: parties.id })
      .from(parties)
      .where(
        and(
          eq(parties.businessId, businessId),
          eq(parties.id, entityId),
          eq(parties.isDeleted, false),
        ),
      )
      .limit(1);
    return Boolean(row);
  }

  return false;
}

function salesDocumentTypeFilter(types: readonly string[]) {
  return or(
    ...types.map((type) =>
      eq(
        salesDocuments.documentType,
        type as (typeof salesDocuments.$inferSelect)['documentType'],
      ),
    ),
  )!;
}

function purchaseDocumentTypeFilter(types: readonly string[]) {
  return or(
    ...types.map((type) =>
      eq(
        purchaseDocuments.documentType,
        type as (typeof purchaseDocuments.$inferSelect)['documentType'],
      ),
    ),
  )!;
}
