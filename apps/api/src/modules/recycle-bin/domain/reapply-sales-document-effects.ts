import type { Database } from '../../../db/client';
import { reverseInventoryForDocument } from './reverse-document-inventory';
import { ledgerEntries } from '../../../db/schema/accounting/tables';
import { normalizeMoney } from '../../inventory/inventory.utils';
import {
  getDefaultGodown,
  recordMovementAndUpdateStock,
} from '../../inventory/inventory-stock.service';
import type { SalesDocumentRepository } from '../../sales/sales-document.repository';
import type { SalesDocumentType } from '../../sales/sales-document.types';
import {
  LEDGER_ON_FINALIZE_TYPES,
  movementTypeForDocument,
  postLedgerReversal,
  shouldSkipStockDeduction,
  STOCK_ON_FINALIZE_TYPES,
} from '../../sales/sales-finalize.service';

type DbTransaction = Parameters<Parameters<Database['transaction']>[0]>[0];

export async function applySalesDocumentStockAndLedger(
  db: Database,
  tx: DbTransaction,
  repository: SalesDocumentRepository,
  params: {
    businessId: string;
    documentId: string;
    userId?: string | null;
    godownId?: string;
  },
): Promise<void> {
  const document = await repository.findRowByIdIncludingDeleted(
    params.businessId,
    params.documentId,
  );
  if (!document) return;

  const documentType = document.documentType as SalesDocumentType;
  const lines = await repository.listLines(params.businessId, params.documentId);

  let convertedFromType: SalesDocumentType | null = null;
  if (document.convertedFromId) {
    const source = await repository.findRowByIdIncludingDeleted(
      params.businessId,
      document.convertedFromId,
    );
    convertedFromType = (source?.documentType as SalesDocumentType) ?? null;
  }

  const movementType = movementTypeForDocument(documentType);
  const skipStock = shouldSkipStockDeduction(documentType, convertedFromType);

  if (
    movementType &&
    STOCK_ON_FINALIZE_TYPES.includes(documentType) &&
    !skipStock
  ) {
    const godown = params.godownId
      ? { id: params.godownId }
      : await getDefaultGodown(tx, params.businessId);

    for (const line of lines) {
      const qty = parseFloat(line.quantity);
      const delta =
        documentType === 'sales_return'
          ? normalizeMoney(qty)
          : normalizeMoney(-qty);

      await recordMovementAndUpdateStock(db, tx, {
        businessId: params.businessId,
        itemId: line.itemId,
        godownId: godown.id,
        movementType,
        quantityDelta: delta,
        costPerUnit: line.unitPrice,
        unit: line.unit,
        referenceId: params.documentId,
        referenceType: 'sales_documents',
        createdBy: params.userId ?? null,
        occurredAt: document.documentDate,
      });
    }
  }

  if (LEDGER_ON_FINALIZE_TYPES.includes(documentType) && document.partyId) {
    const total = document.totalAmount;
    const isReturn = documentType === 'sales_return';

    await tx.insert(ledgerEntries).values({
      businessId: params.businessId,
      partyId: document.partyId,
      entryType: isReturn ? 'return' : 'sale',
      debit: isReturn ? '0' : total,
      credit: isReturn ? total : '0',
      balanceAfter: total,
      referenceId: params.documentId,
      referenceType: 'sales_documents',
      entryDate: document.documentDate.toISOString().slice(0, 10),
      description: `${documentType} restored`,
    });
  }
}

export async function reverseSalesDocumentStockAndLedger(
  db: Database,
  tx: DbTransaction,
  repository: SalesDocumentRepository,
  params: {
    businessId: string;
    documentId: string;
    userId?: string | null;
  },
): Promise<void> {
  const document = await repository.findRowByIdIncludingDeleted(
    params.businessId,
    params.documentId,
  );
  if (!document || document.status !== 'finalized') return;

  const documentType = document.documentType as SalesDocumentType;

  await reverseInventoryForDocument(db, tx, {
    businessId: params.businessId,
    referenceType: 'sales_documents',
    referenceId: params.documentId,
    userId: params.userId,
  });

  if (LEDGER_ON_FINALIZE_TYPES.includes(documentType) && document.partyId) {
    await postLedgerReversal(tx, {
      businessId: params.businessId,
      partyId: document.partyId,
      documentId: params.documentId,
      documentType,
      totalAmount: document.totalAmount,
      entryDate: document.documentDate.toISOString().slice(0, 10),
    });
  }
}
