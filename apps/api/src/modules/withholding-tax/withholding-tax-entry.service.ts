import type { Database } from '../../db/client';
import { parties } from '../../db/schema/crm/tables';
import { purchaseDocuments } from '../../db/schema/purchases/tables';
import { salesDocuments } from '../../db/schema/sales/tables';
import { payments } from '../../db/schema/accounting/tables';
import { and, eq } from 'drizzle-orm';
import { normalizeMoney, parseMoney } from '../inventory/inventory.utils';
import { WithholdingTaxEntryRepository } from './withholding-tax-entry.repository';
import { WithholdingTaxSectionRepository } from './withholding-tax-section.repository';

type DbLike = Pick<Database, 'select' | 'insert' | 'delete' | 'update'>;

export class WithholdingTaxEntryService {
  private readonly entries: WithholdingTaxEntryRepository;
  private readonly sections: WithholdingTaxSectionRepository;

  constructor(private readonly db: Database) {
    this.entries = new WithholdingTaxEntryRepository(db);
    this.sections = new WithholdingTaxSectionRepository(db);
  }

  async syncFromSaleDocument(
    tx: DbLike,
    params: {
      businessId: string;
      documentId: string;
      userId?: string | null;
    },
  ): Promise<void> {
    const repo = new WithholdingTaxEntryRepository(tx as Database);
    const [doc] = await tx
      .select({
        partyId: salesDocuments.partyId,
        tcsSectionId: salesDocuments.tcsSectionId,
        tcsRate: salesDocuments.tcsRate,
        tcsBaseAmount: salesDocuments.tcsBaseAmount,
        tcsAmount: salesDocuments.tcsAmount,
        documentDate: salesDocuments.documentDate,
        documentNumber: salesDocuments.documentNumber,
      })
      .from(salesDocuments)
      .where(
        and(
          eq(salesDocuments.businessId, params.businessId),
          eq(salesDocuments.id, params.documentId),
        ),
      )
      .limit(1);

    if (!doc) return;

    if (parseMoney(doc.tcsAmount ?? '0') <= 0) {
      await repo.upsertForSource({
        businessId: params.businessId,
        kind: 'tcs',
        direction: 'receivable',
        sectionId: doc.tcsSectionId ?? null,
        sectionCode: '—',
        rate: doc.tcsRate ?? '0',
        baseAmount: doc.tcsBaseAmount ?? '0',
        taxAmount: '0',
        partyId: doc.partyId ?? null,
        sourceType: 'sales_documents',
        sourceId: params.documentId,
        entryDate: doc.documentDate,
        createdBy: params.userId ?? null,
        updatedBy: params.userId ?? null,
      });
      return;
    }

    const section = doc.tcsSectionId
      ? await this.sections.findById(params.businessId, doc.tcsSectionId)
      : null;
    const party = doc.partyId
      ? await this.loadParty(tx, params.businessId, doc.partyId)
      : null;

    await repo.upsertForSource({
      businessId: params.businessId,
      kind: 'tcs',
      direction: 'receivable',
      sectionId: doc.tcsSectionId,
      sectionCode: section?.code ?? '—',
      rate: doc.tcsRate ?? section?.rate ?? '0',
      baseAmount: doc.tcsBaseAmount ?? '0',
      taxAmount: doc.tcsAmount ?? '0',
      partyId: doc.partyId,
      partyPan: party?.pan ?? null,
      partyName: party?.name ?? null,
      sourceType: 'sales_documents',
      sourceId: params.documentId,
      entryDate: doc.documentDate,
      createdBy: params.userId ?? null,
      updatedBy: params.userId ?? null,
    });
  }

  async syncFromPurchaseDocument(
    tx: DbLike,
    params: {
      businessId: string;
      documentId: string;
      userId?: string | null;
    },
  ): Promise<void> {
    const repo = new WithholdingTaxEntryRepository(tx as Database);
    const [doc] = await tx
      .select({
        partyId: purchaseDocuments.partyId,
        tcsSectionId: purchaseDocuments.tcsSectionId,
        tcsRate: purchaseDocuments.tcsRate,
        tcsBaseAmount: purchaseDocuments.tcsBaseAmount,
        tcsAmount: purchaseDocuments.tcsAmount,
        documentDate: purchaseDocuments.documentDate,
      })
      .from(purchaseDocuments)
      .where(
        and(
          eq(purchaseDocuments.businessId, params.businessId),
          eq(purchaseDocuments.id, params.documentId),
        ),
      )
      .limit(1);

    if (!doc) return;

    if (parseMoney(doc.tcsAmount ?? '0') <= 0) {
      await repo.upsertForSource({
        businessId: params.businessId,
        kind: 'tcs',
        direction: 'payable',
        sectionId: doc.tcsSectionId ?? null,
        sectionCode: '—',
        rate: doc.tcsRate ?? '0',
        baseAmount: doc.tcsBaseAmount ?? '0',
        taxAmount: '0',
        partyId: doc.partyId ?? null,
        sourceType: 'purchase_documents',
        sourceId: params.documentId,
        entryDate: doc.documentDate,
        createdBy: params.userId ?? null,
        updatedBy: params.userId ?? null,
      });
      return;
    }

    const section = doc.tcsSectionId
      ? await this.sections.findById(params.businessId, doc.tcsSectionId)
      : null;
    const party = doc.partyId
      ? await this.loadParty(tx, params.businessId, doc.partyId)
      : null;

    await repo.upsertForSource({
      businessId: params.businessId,
      kind: 'tcs',
      direction: 'payable',
      sectionId: doc.tcsSectionId,
      sectionCode: section?.code ?? '—',
      rate: doc.tcsRate ?? section?.rate ?? '0',
      baseAmount: doc.tcsBaseAmount ?? '0',
      taxAmount: doc.tcsAmount ?? '0',
      partyId: doc.partyId,
      partyPan: party?.pan ?? null,
      partyName: party?.name ?? null,
      sourceType: 'purchase_documents',
      sourceId: params.documentId,
      entryDate: doc.documentDate,
      createdBy: params.userId ?? null,
      updatedBy: params.userId ?? null,
    });
  }

  async syncFromPayment(
    tx: DbLike,
    params: {
      businessId: string;
      paymentId: string;
      userId?: string | null;
    },
  ): Promise<void> {
    const repo = new WithholdingTaxEntryRepository(tx as Database);
    const [payment] = await tx
      .select()
      .from(payments)
      .where(
        and(
          eq(payments.businessId, params.businessId),
          eq(payments.id, params.paymentId),
        ),
      )
      .limit(1);

    if (!payment) return;

    const tdsAmount = payment.tdsAmount ?? '0';
    const direction =
      payment.direction === 'paid' ? 'payable' : ('receivable' as const);
    const section = payment.tdsSectionId
      ? await this.sections.findById(params.businessId, payment.tdsSectionId)
      : null;
    const party = await this.loadParty(
      tx,
      params.businessId,
      payment.partyId,
    );

    const grossBase = normalizeMoney(
      parseMoney(payment.amount) + parseMoney(tdsAmount),
    );

    await repo.upsertForSource({
      businessId: params.businessId,
      kind: 'tds',
      direction,
      sectionId: payment.tdsSectionId,
      sectionCode: section?.code ?? '—',
      rate: payment.tdsRate ?? section?.rate ?? '0',
      baseAmount: grossBase,
      taxAmount: tdsAmount,
      partyId: payment.partyId,
      partyPan: party?.pan ?? null,
      partyName: party?.name ?? null,
      sourceType: 'payments',
      sourceId: params.paymentId,
      entryDate: payment.paymentDate,
      createdBy: params.userId ?? null,
      updatedBy: params.userId ?? null,
    });
  }

  private async loadParty(
    tx: DbLike,
    businessId: string,
    partyId: string,
  ): Promise<{ name: string; pan: string | null } | null> {
    const [row] = await tx
      .select({ name: parties.name, pan: parties.pan })
      .from(parties)
      .where(and(eq(parties.businessId, businessId), eq(parties.id, partyId)))
      .limit(1);
    return row ?? null;
  }
}
