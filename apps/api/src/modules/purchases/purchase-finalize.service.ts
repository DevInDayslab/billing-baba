import { and, eq, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { ledgerEntries } from '../../db/schema/accounting/tables';
import { purchaseDocuments } from '../../db/schema/purchases/tables';
import { assignDocumentNumber } from '../../shared/documents/document-numbering.service';
import { AppError } from '../../shared/errors/app-error';
import { normalizeMoney } from '../inventory/inventory.utils';
import {
  getDefaultGodown,
  recordMovementAndUpdateStock,
} from '../inventory/inventory-stock.service';
import type { PurchaseDocumentRepository } from './purchase-document.repository';
import type { PurchaseDocumentType } from './purchase-document.types';

const STOCK_ON_FINALIZE_TYPES: PurchaseDocumentType[] = [
  'purchase_bill',
  'purchase_return',
];

const LEDGER_ON_FINALIZE_TYPES: PurchaseDocumentType[] = [
  'purchase_bill',
  'purchase_return',
];

function movementTypeForDocument(
  documentType: PurchaseDocumentType,
): 'purchase' | 'purchase_return' | null {
  switch (documentType) {
    case 'purchase_bill':
      return 'purchase';
    case 'purchase_return':
      return 'purchase_return';
    default:
      return null;
  }
}

export async function finalizePurchaseDocument(
  db: Database,
  repository: PurchaseDocumentRepository,
  params: {
    businessId: string;
    documentId: string;
    userId?: string;
    godownId?: string;
  },
): Promise<{
  documentNumber: string | null;
  documentType: PurchaseDocumentType;
}> {
  const document = await repository.findRowById(
    params.businessId,
    params.documentId,
  );

  if (!document) {
    throw new AppError('NOT_FOUND', 'Purchase document not found', 404);
  }

  if (document.status !== 'draft') {
    throw new AppError(
      'DOCUMENT_NOT_EDITABLE',
      'Only draft documents can be finalized',
      409,
    );
  }

  const lines = await repository.listLines(
    params.businessId,
    params.documentId,
  );
  if (lines.length === 0) {
    throw new AppError(
      'VALIDATION_ERROR',
      'Cannot finalize document without lines',
      422,
      { lines: ['At least one line is required'] },
    );
  }

  const movementType = movementTypeForDocument(
    document.documentType as PurchaseDocumentType,
  );

  if (params.godownId) {
    const godownValid = await repository.godownExists(
      params.businessId,
      params.godownId,
    );
    if (!godownValid) {
      throw new AppError('NOT_FOUND', 'Godown not found', 404);
    }
  }

  return db.transaction(async (tx) => {
    let documentNumber: string | null = document.documentNumber;

    if (!documentNumber) {
      documentNumber = await assignDocumentNumber(
        tx,
        params.businessId,
        document.documentSeries,
        document.documentDate,
      );
    }

    if (
      movementType &&
      STOCK_ON_FINALIZE_TYPES.includes(
        document.documentType as PurchaseDocumentType,
      )
    ) {
      const godown = params.godownId
        ? { id: params.godownId }
        : await getDefaultGodown(tx, params.businessId);

      for (const line of lines) {
        const qty = parseFloat(line.quantity);
        const delta =
          document.documentType === 'purchase_return'
            ? normalizeMoney(-qty)
            : normalizeMoney(qty);

        await recordMovementAndUpdateStock(db, tx, {
          businessId: params.businessId,
          itemId: line.itemId,
          godownId: godown.id,
          movementType,
          quantityDelta: delta,
          costPerUnit: line.unitPrice,
          unit: line.unit,
          referenceId: params.documentId,
          referenceType: 'purchase_documents',
          createdBy: params.userId ?? null,
          occurredAt: document.documentDate,
        });
      }
    }

    if (
      LEDGER_ON_FINALIZE_TYPES.includes(
        document.documentType as PurchaseDocumentType,
      )
    ) {
      const total = document.totalAmount;
      const isReturn = document.documentType === 'purchase_return';

      await tx.insert(ledgerEntries).values({
        businessId: params.businessId,
        partyId: document.partyId,
        entryType: isReturn ? 'return' : 'purchase',
        debit: isReturn ? total : '0',
        credit: isReturn ? '0' : total,
        balanceAfter: total,
        referenceId: params.documentId,
        referenceType: 'purchase_documents',
        entryDate: document.documentDate.toISOString().slice(0, 10),
        description: `${document.documentType} finalized`,
      });
    }

    const [finalized] = await tx
      .update(purchaseDocuments)
      .set({
        status: 'finalized',
        documentNumber,
        updatedBy: params.userId ?? null,
        updatedAt: new Date(),
        syncVersion: sql`${purchaseDocuments.syncVersion} + 1`,
      })
      .where(
        and(
          eq(purchaseDocuments.id, params.documentId),
          eq(purchaseDocuments.businessId, params.businessId),
          eq(purchaseDocuments.status, 'draft'),
          eq(purchaseDocuments.isDeleted, false),
        ),
      )
      .returning();

    if (!finalized) {
      throw new AppError('NOT_FOUND', 'Purchase document not found', 404);
    }

    return {
      documentNumber,
      documentType: document.documentType as PurchaseDocumentType,
    };
  });
}

export { LEDGER_ON_FINALIZE_TYPES, STOCK_ON_FINALIZE_TYPES };
