import { and, eq, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { ledgerEntries } from '../../db/schema/accounting/tables';
import { parties } from '../../db/schema/crm/tables';
import { salesDocuments } from '../../db/schema/sales/tables';
import { AppError } from '../../shared/errors/app-error';
import { normalizeMoney } from '../inventory/inventory.utils';
import {
  getDefaultGodown,
  recordMovementAndUpdateStock,
} from '../inventory/inventory-stock.service';
import { LoyaltyService } from '../loyalty/loyalty.service';
import type { SaleLoyaltyResult } from '../loyalty/loyalty.types';
import { RUPEES_PER_REDEEMED_POINT } from '../loyalty/loyalty.utils';
import { syncLoyaltyRedeemedExpense } from '../purchases/expense-sync.service';
import type { SalesDocumentRepository } from './sales-document.repository';
import type { SalesDocumentType } from './sales-document.types';
import {
  type FinalizeSalePaymentInput,
  recordSaleFinalizePayment,
} from './sales-finalize-payment.service';
import { assignDocumentNumber } from './sales-numbering.service';

type DbTransaction = Parameters<Parameters<Database['transaction']>[0]>[0];

const STOCK_ON_FINALIZE_TYPES: SalesDocumentType[] = [
  'delivery_challan',
  'tax_invoice',
  'bill_of_supply',
  'normal_invoice',
  'pos',
  'sales_return',
];

const LEDGER_ON_FINALIZE_TYPES: SalesDocumentType[] = [
  'tax_invoice',
  'bill_of_supply',
  'normal_invoice',
  'pos',
  'sales_return',
];

function movementTypeForDocument(
  documentType: SalesDocumentType,
): 'sale' | 'sales_return' | 'challan' | null {
  switch (documentType) {
    case 'delivery_challan':
      return 'challan';
    case 'tax_invoice':
    case 'bill_of_supply':
    case 'normal_invoice':
    case 'pos':
      return 'sale';
    case 'sales_return':
      return 'sales_return';
    default:
      return null;
  }
}

function shouldSkipStockDeduction(
  documentType: SalesDocumentType,
  convertedFromType: SalesDocumentType | null,
): boolean {
  if (!convertedFromType) {
    return false;
  }

  const invoiceTypes: SalesDocumentType[] = [
    'tax_invoice',
    'bill_of_supply',
    'normal_invoice',
    'pos',
  ];

  if (!invoiceTypes.includes(documentType)) {
    return false;
  }

  // Skip re-deduction when converting from any document that already moved stock
  // (challan→invoice, kaccha→pakka, etc.)
  const stockDeductingSourceTypes: SalesDocumentType[] = [
    'delivery_challan',
    'tax_invoice',
    'bill_of_supply',
    'normal_invoice',
    'pos',
  ];

  return stockDeductingSourceTypes.includes(convertedFromType);
}

export async function finalizeSalesDocument(
  db: Database,
  repository: SalesDocumentRepository,
  params: {
    businessId: string;
    documentId: string;
    userId?: string;
    godownId?: string;
    loyaltyPointsRedeemed?: string;
    payment?: FinalizeSalePaymentInput;
  },
): Promise<{
  documentNumber: string | null;
  documentType: SalesDocumentType;
  loyalty: SaleLoyaltyResult | null;
  paidAmount: string;
  paymentMode: string | null;
}> {
  const document = await repository.findRowById(
    params.businessId,
    params.documentId,
  );

  if (!document) {
    throw new AppError('NOT_FOUND', 'Sales document not found', 404);
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

  let convertedFromType: SalesDocumentType | null = null;
  if (document.convertedFromId) {
    const source = await repository.findRowById(
      params.businessId,
      document.convertedFromId,
    );
    convertedFromType = (source?.documentType as SalesDocumentType) ?? null;
  }

  const movementType = movementTypeForDocument(
    document.documentType as SalesDocumentType,
  );
  const skipStock = shouldSkipStockDeduction(
    document.documentType as SalesDocumentType,
    convertedFromType,
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
        document.documentType as SalesDocumentType,
      ) &&
      !skipStock
    ) {
      const godown = params.godownId
        ? { id: params.godownId }
        : await getDefaultGodown(tx, params.businessId);

      for (const line of lines) {
        const qty = parseFloat(line.quantity);
        const delta =
          document.documentType === 'sales_return'
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

    if (
      LEDGER_ON_FINALIZE_TYPES.includes(
        document.documentType as SalesDocumentType,
      ) &&
      document.partyId
    ) {
      const total = document.totalAmount;
      const isReturn = document.documentType === 'sales_return';

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
        description: `${document.documentType} finalized`,
      });
    }

    const [finalized] = await tx
      .update(salesDocuments)
      .set({
        status: 'finalized',
        documentNumber,
        updatedBy: params.userId ?? null,
        updatedAt: new Date(),
        syncVersion: sql`${salesDocuments.syncVersion} + 1`,
      })
      .where(
        and(
          eq(salesDocuments.id, params.documentId),
          eq(salesDocuments.businessId, params.businessId),
          eq(salesDocuments.status, 'draft'),
          eq(salesDocuments.isDeleted, false),
        ),
      )
      .returning();

    if (!finalized) {
      throw new AppError('NOT_FOUND', 'Sales document not found', 404);
    }

    let loyalty: SaleLoyaltyResult | null = null;
    if (document.partyId) {
      const [partyRow] = await tx
        .select({ partyType: parties.partyType })
        .from(parties)
        .where(
          and(
            eq(parties.businessId, params.businessId),
            eq(parties.id, document.partyId),
            eq(parties.isDeleted, false),
          ),
        )
        .limit(1);

      if (partyRow) {
        const [totalsRow] = await tx
          .select({ totalAmount: salesDocuments.totalAmount })
          .from(salesDocuments)
          .where(
            and(
              eq(salesDocuments.businessId, params.businessId),
              eq(salesDocuments.id, params.documentId),
            ),
          )
          .limit(1);

        const loyaltyService = new LoyaltyService(db);
        loyalty = await loyaltyService.applySaleLoyalty(tx, {
          businessId: params.businessId,
          partyId: document.partyId,
          partyType: partyRow.partyType,
          documentId: params.documentId,
          documentType: document.documentType as SalesDocumentType,
          totalAmount: totalsRow?.totalAmount ?? document.totalAmount,
          loyaltyPointsRedeemed: params.loyaltyPointsRedeemed,
          userId: params.userId,
        });
      }
    }

    if (document.partyId && loyalty) {
      const redeemedPoints = parseFloat(loyalty.redeemed_points || '0');
      const loyaltyValue = normalizeMoney(
        redeemedPoints * RUPEES_PER_REDEEMED_POINT,
      );
      await syncLoyaltyRedeemedExpense(tx as unknown as Database, {
        businessId: params.businessId,
        userId: params.userId,
        documentId: params.documentId,
        documentNumber,
        partyId: document.partyId,
        expenseDate: document.documentDate.toISOString().slice(0, 10),
        loyaltyPointsRedeemed: loyalty.redeemed_points,
        loyaltyValueRedeemed: loyaltyValue,
      });
    }

    let paidAmount = '0';
    let paymentMode: string | null = null;

    if (params.payment && document.partyId) {
      const paymentResult = await recordSaleFinalizePayment(tx, {
        businessId: params.businessId,
        documentId: params.documentId,
        partyId: document.partyId,
        documentTotal: document.totalAmount,
        documentDate: document.documentDate,
        documentType: document.documentType as SalesDocumentType,
        userId: params.userId,
        payment: params.payment,
      });
      paidAmount = paymentResult.paidAmount;
      paymentMode = paymentResult.paymentMode;
    }

    return {
      documentNumber,
      documentType: document.documentType as SalesDocumentType,
      loyalty,
      paidAmount,
      paymentMode,
    };
  });
}

export async function postLedgerReversal(
  tx: DbTransaction,
  params: {
    businessId: string;
    partyId: string;
    documentId: string;
    documentType: SalesDocumentType;
    totalAmount: string;
    entryDate: string;
  },
): Promise<void> {
  const isReturn = params.documentType === 'sales_return';

  await tx.insert(ledgerEntries).values({
    businessId: params.businessId,
    partyId: params.partyId,
    entryType: isReturn ? 'return' : 'sale',
    debit: isReturn ? params.totalAmount : '0',
    credit: isReturn ? '0' : params.totalAmount,
    balanceAfter: '0',
    referenceId: params.documentId,
    referenceType: 'sales_documents',
    entryDate: params.entryDate,
    description: `${params.documentType} cancelled`,
  });
}

export async function findConvertedChainRoot(
  repository: SalesDocumentRepository,
  businessId: string,
  convertedFromId: string,
): Promise<string> {
  let currentId = convertedFromId;
  for (let depth = 0; depth < 10; depth += 1) {
    const doc = await repository.findRowById(businessId, currentId);
    if (!doc?.convertedFromId) {
      return currentId;
    }
    currentId = doc.convertedFromId;
  }
  return currentId;
}

export { LEDGER_ON_FINALIZE_TYPES, STOCK_ON_FINALIZE_TYPES };
