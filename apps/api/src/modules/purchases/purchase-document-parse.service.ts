import { and, eq, ilike } from 'drizzle-orm';
import { type Database, getDb } from '../../db/client';
import { parties } from '../../db/schema/crm/tables';
import { AppError } from '../../shared/errors/app-error';
import { BusinessMembershipRepository } from '../../shared/repositories/business-membership.repository';
import { parsePurchaseDocumentWithGemini } from './purchase-document-gemini.parser';
import { logValidationOrMappingError } from './purchase-document-parse.debug';
import { normalizeParsedDocument } from './purchase-document-parse.normalizer';
import {
  ALLOWED_PARSE_EXTENSIONS,
  ALLOWED_PARSE_MIME_TYPES,
} from './purchase-document-parse.schema';
import type {
  ParseDocumentInput,
  ParsedPurchaseDocument,
} from './purchase-document-parse.types';

const MAX_FILE_SIZE_BYTES = 5 * 1024 * 1024;

function extensionFor(filename: string): string {
  const parts = filename.toLowerCase().split('.');
  return parts.length > 1 ? (parts.at(-1) ?? '') : '';
}

function emptyParsedDocument(): ParsedPurchaseDocument {
  return {
    vendor_name: null,
    party_id: null,
    gstin: null,
    vendor_phone: null,
    vendor_email: null,
    vendor_address: null,
    vendor_city: null,
    vendor_pincode: null,
    vendor_state: null,
    e_way_bill_number: null,
    supplier_invoice_number: null,
    invoice_number: null,
    invoice_date: null,
    due_date: null,
    state_of_supply: null,
    payment_mode: null,
    payment_amount: null,
    notes: null,
    terms_notes: null,
    subtotal: null,
    discount_total: null,
    tax_amount: null,
    total_amount: null,
    lines: [],
  };
}

export class PurchaseDocumentParseService {
  private readonly membershipRepository: BusinessMembershipRepository;

  constructor(db: Database | null = getDb()) {
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.membershipRepository = new BusinessMembershipRepository(db);
    this.db = db;
  }

  private readonly db: Database;

  validateUpload(input: ParseDocumentInput): void {
    if (input.buffer.length === 0) {
      throw new AppError('VALIDATION_ERROR', 'Uploaded file is empty', 400);
    }

    if (input.buffer.length > MAX_FILE_SIZE_BYTES) {
      throw new AppError(
        'VALIDATION_ERROR',
        'File size exceeds the 5 MB limit',
        400,
      );
    }

    const extension = extensionFor(input.filename);
    if (!ALLOWED_PARSE_EXTENSIONS.has(extension)) {
      throw new AppError(
        'VALIDATION_ERROR',
        'Only .jpg, .jpeg, .png, and .pdf files are supported',
        400,
      );
    }

    if (
      input.mimeType &&
      input.mimeType !== 'application/octet-stream' &&
      !ALLOWED_PARSE_MIME_TYPES.has(input.mimeType.toLowerCase())
    ) {
      throw new AppError(
        'VALIDATION_ERROR',
        'Unsupported file type. Use JPG, PNG, or PDF',
        400,
      );
    }
  }

  async parseDocument(
    businessId: string,
    accountId: string,
    input: ParseDocumentInput,
  ): Promise<ParsedPurchaseDocument> {
    this.validateUpload(input);

    const raw = await this.invokeParser(input);

    let normalized: ParsedPurchaseDocument;
    try {
      normalized = normalizeParsedDocument(raw);
    } catch (error) {
      logValidationOrMappingError('normalizeParsedDocument', error, raw);
      throw error;
    }

    try {
      return await this.enrichWithPartyMatch(businessId, accountId, normalized);
    } catch (error) {
      logValidationOrMappingError('enrichWithPartyMatch', error, normalized);
      throw error;
    }
  }

  private async invokeParser(input: ParseDocumentInput): Promise<unknown> {
    const geminiApiKey = process.env.GEMINI_API_KEY?.trim();
    if (geminiApiKey) {
      return parsePurchaseDocumentWithGemini(input);
    }

    const parseUrl = process.env.PURCHASE_DOCUMENT_PARSE_URL?.trim();
    if (parseUrl) {
      return this.parseViaHttp(parseUrl, input);
    }

    if (process.env.ENABLE_MOCK_PURCHASE_PARSE === 'true') {
      await new Promise((resolve) => setTimeout(resolve, 800));
      return emptyParsedDocument();
    }

    throw new AppError(
      'PARSE_SERVICE_UNAVAILABLE',
      'Purchase document parsing is not configured. Set GEMINI_API_KEY on the server.',
      503,
    );
  }

  private async parseViaHttp(
    url: string,
    input: ParseDocumentInput,
  ): Promise<unknown> {
    const form = new FormData();
    const blob = new Blob([new Uint8Array(input.buffer)], {
      type: input.mimeType || 'application/octet-stream',
    });
    form.append('file', blob, input.filename);

    const response = await fetch(url, {
      method: 'POST',
      body: form,
    });

    if (!response.ok) {
      throw new AppError(
        'PARSE_FAILED',
        'Failed to parse the uploaded document',
        502,
      );
    }

    const payload = (await response.json()) as { data?: unknown };
    return payload.data ?? payload;
  }

  private async enrichWithPartyMatch(
    businessId: string,
    accountId: string,
    parsed: ParsedPurchaseDocument,
  ): Promise<ParsedPurchaseDocument> {
    if (parsed.party_id) {
      const party = await this.findPartyById(
        businessId,
        accountId,
        parsed.party_id,
      );
      if (party) {
        return {
          ...parsed,
          party_id: party.id,
          vendor_name: party.name,
          gstin: parsed.gstin ?? party.gstin,
        };
      }
    }

    if (parsed.gstin) {
      const party = await this.findPartyByGstin(businessId, parsed.gstin);
      if (party) {
        return {
          ...parsed,
          party_id: party.id,
          vendor_name: party.name,
          gstin: party.gstin,
        };
      }
    }

    if (parsed.vendor_name) {
      const party = await this.findPartyByName(businessId, parsed.vendor_name);
      if (party) {
        return {
          ...parsed,
          party_id: party.id,
          vendor_name: party.name,
          gstin: parsed.gstin ?? party.gstin,
        };
      }
    }

    return parsed;
  }

  private async findPartyById(
    businessId: string,
    accountId: string,
    partyId: string,
  ): Promise<{ id: string; name: string; gstin: string | null } | null> {
    const [row] = await this.db
      .select({
        id: parties.id,
        name: parties.name,
        gstin: parties.gstin,
      })
      .from(parties)
      .where(
        and(
          eq(parties.businessId, businessId),
          eq(parties.id, partyId),
          eq(parties.isDeleted, false),
        ),
      )
      .limit(1);

    if (!row) return null;

    const hasAccess = await this.hasBusinessMembership(businessId, accountId);
    if (!hasAccess) return null;

    return row;
  }

  private async findPartyByGstin(
    businessId: string,
    gstin: string,
  ): Promise<{ id: string; name: string; gstin: string | null } | null> {
    const [row] = await this.db
      .select({
        id: parties.id,
        name: parties.name,
        gstin: parties.gstin,
      })
      .from(parties)
      .where(
        and(
          eq(parties.businessId, businessId),
          eq(parties.gstin, gstin.trim().toUpperCase()),
          eq(parties.isDeleted, false),
        ),
      )
      .limit(1);

    return row ?? null;
  }

  private async findPartyByName(
    businessId: string,
    vendorName: string,
  ): Promise<{ id: string; name: string; gstin: string | null } | null> {
    const [row] = await this.db
      .select({
        id: parties.id,
        name: parties.name,
        gstin: parties.gstin,
      })
      .from(parties)
      .where(
        and(
          eq(parties.businessId, businessId),
          ilike(parties.name, vendorName.trim()),
          eq(parties.isDeleted, false),
        ),
      )
      .limit(1);

    return row ?? null;
  }

  private async hasBusinessMembership(
    businessId: string,
    accountId: string,
  ): Promise<boolean> {
    return this.membershipRepository.hasBusinessMembership(
      businessId,
      accountId,
    );
  }
}
