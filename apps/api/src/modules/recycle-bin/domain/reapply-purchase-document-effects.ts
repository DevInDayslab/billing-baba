import type { Database } from '../../../db/client';
import { reverseInventoryForDocument } from './reverse-document-inventory';
import { ledgerEntries } from '../../../db/schema/accounting/tables';
import { normalizeMoney } from '../../inventory/inventory.utils';
import {
  getDefaultGodown,
  recordMovementAndUpdateStock,
} from '../../inventory/inventory-stock.service';
import type { PurchaseDocumentRepository } from '../../purchases/purchase-document.repository';
import type { PurchaseDocumentType } from '../../purchases/purchase-document.types';
import {
  LEDGER_ON_FINALIZE_TYPES,
  postPurchaseLedgerReversal,
  STOCK_ON_FINALIZE_TYPES,
} from '../../purchases/purchase-finalize.service';

type DbTransaction = Parameters<Parameters<Database['transaction']>[0]>[0];

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

export async function applyPurchaseDocumentStockAndLedger(
  db: Database,
  tx: DbTransaction,
  repository: PurchaseDocumentRepository,
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

  const documentType = document.documentType as PurchaseDocumentType;
  const lines = await repository.listLines(params.businessId, params.documentId);
  const movementType = movementTypeForDocument(documentType);

  if (movementType && STOCK_ON_FINALIZE_TYPES.includes(documentType)) {
    const godown = params.godownId
      ? { id: params.godownId }
      : await getDefaultGodown(tx, params.businessId);

    for (const line of lines) {
      const qty = parseFloat(line.quantity);
      const delta =
        documentType === 'purchase_return'
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

  if (LEDGER_ON_FINALIZE_TYPES.includes(documentType)) {
    const total = document.totalAmount;
    const isReturn = documentType === 'purchase_return';

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
      description: `${documentType} restored`,
    });
  }
}

export async function reversePurchaseDocumentStockAndLedger(
  db: Database,
  tx: DbTransaction,
  repository: PurchaseDocumentRepository,
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

  const documentType = document.documentType as PurchaseDocumentType;

  await reverseInventoryForDocument(db, tx, {
    businessId: params.businessId,
    referenceType: 'purchase_documents',
    referenceId: params.documentId,
    userId: params.userId,
  });

  if (LEDGER_ON_FINALIZE_TYPES.includes(documentType)) {
    await postPurchaseLedgerReversal(tx, {
      businessId: params.businessId,
      partyId: document.partyId,
      documentId: params.documentId,
      documentType,
      totalAmount: document.totalAmount,
      entryDate: document.documentDate.toISOString().slice(0, 10),
    });
  }
}
