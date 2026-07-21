import { and, eq } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { payments } from '../../db/schema/accounting/tables';
import { purchaseDocuments } from '../../db/schema/purchases/tables';
import { salesDocuments } from '../../db/schema/sales/tables';
import { AppError } from '../../shared/errors/app-error';
import type {
  GeneratedDocumentKind,
  GeneratedDocumentSourceType,
} from './generated-document.constants';
import type { SourceVersionSnapshot } from './generated-document.types';

export async function resolveGeneratedSourceVersion(
  db: Database,
  businessId: string,
  sourceType: GeneratedDocumentSourceType,
  sourceId: string,
): Promise<SourceVersionSnapshot> {
  switch (sourceType) {
    case 'sale_document': {
      const [row] = await db
        .select({
          syncVersion: salesDocuments.syncVersion,
        })
        .from(salesDocuments)
        .where(
          and(
            eq(salesDocuments.businessId, businessId),
            eq(salesDocuments.id, sourceId),
            eq(salesDocuments.isDeleted, false),
          ),
        )
        .limit(1);
      if (!row) {
        throw new AppError('NOT_FOUND', 'Sales document not found', 404);
      }
      return { sourceVersion: row.syncVersion };
    }
    case 'purchase_document': {
      const [row] = await db
        .select({
          syncVersion: purchaseDocuments.syncVersion,
        })
        .from(purchaseDocuments)
        .where(
          and(
            eq(purchaseDocuments.businessId, businessId),
            eq(purchaseDocuments.id, sourceId),
            eq(purchaseDocuments.isDeleted, false),
          ),
        )
        .limit(1);
      if (!row) {
        throw new AppError('NOT_FOUND', 'Purchase document not found', 404);
      }
      return { sourceVersion: row.syncVersion };
    }
    case 'payment': {
      const [row] = await db
        .select({
          syncVersion: payments.syncVersion,
        })
        .from(payments)
        .where(
          and(
            eq(payments.businessId, businessId),
            eq(payments.id, sourceId),
            eq(payments.isDeleted, false),
          ),
        )
        .limit(1);
      if (!row) {
        throw new AppError('NOT_FOUND', 'Payment not found', 404);
      }
      return { sourceVersion: row.syncVersion };
    }
    case 'report':
      // Reports are keyed by client-provided source_id; version is always 1 unless
      // the client rotates the fingerprint when parameters change.
      return { sourceVersion: 1 };
    default:
      throw new AppError('VALIDATION_ERROR', 'Unsupported source type', 400);
  }
}

export async function assertGeneratedKindMatchesSource(
  db: Database,
  businessId: string,
  documentKind: GeneratedDocumentKind,
  sourceType: GeneratedDocumentSourceType,
  sourceId: string,
): Promise<void> {
  if (sourceType === 'report') return;

  if (sourceType === 'sale_document') {
    const [row] = await db
      .select({ documentType: salesDocuments.documentType })
      .from(salesDocuments)
      .where(
        and(
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.id, sourceId),
          eq(salesDocuments.isDeleted, false),
        ),
      )
      .limit(1);
    if (!row) {
      throw new AppError('NOT_FOUND', 'Sales document not found', 404);
    }
    const valid = kindMatchesSalesDocument(documentKind, row.documentType);
    if (!valid) {
      throw new AppError(
        'VALIDATION_ERROR',
        'document_kind does not match sales document type',
        400,
      );
    }
    return;
  }

  if (sourceType === 'purchase_document') {
    const [row] = await db
      .select({ documentType: purchaseDocuments.documentType })
      .from(purchaseDocuments)
      .where(
        and(
          eq(purchaseDocuments.businessId, businessId),
          eq(purchaseDocuments.id, sourceId),
          eq(purchaseDocuments.isDeleted, false),
        ),
      )
      .limit(1);
    if (!row) {
      throw new AppError('NOT_FOUND', 'Purchase document not found', 404);
    }
    if (documentKind !== 'purchase_pdf') {
      throw new AppError(
        'VALIDATION_ERROR',
        'document_kind must be purchase_pdf for purchase documents',
        400,
      );
    }
    return;
  }

  if (sourceType === 'payment' && documentKind !== 'receipt_pdf') {
    throw new AppError(
      'VALIDATION_ERROR',
      'document_kind must be receipt_pdf for payments',
      400,
    );
  }
}

function kindMatchesSalesDocument(
  kind: GeneratedDocumentKind,
  documentType: string,
): boolean {
  switch (kind) {
    case 'invoice_pdf':
      return [
        'tax_invoice',
        'bill_of_supply',
        'normal_invoice',
        'pos',
        'sales_return',
      ].includes(documentType);
    case 'estimate_pdf':
      return documentType === 'estimate';
    case 'delivery_challan_pdf':
      return documentType === 'delivery_challan';
    default:
      return false;
  }
}
