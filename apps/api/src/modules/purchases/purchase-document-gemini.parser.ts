import { AppError } from '../../shared/errors/app-error';
import {
  getGeminiDeveloperClient,
  logGeminiApiError,
  logGeminiRequestStart,
  requireGeminiApiKey,
} from '../../shared/gemini/gemini-client';
import {
  logGeminiGenerateContentEnd,
  logGeminiGenerateContentStart,
  logGeminiParsedJson,
  logGeminiRawResponseText,
  logJsonParseError,
} from './purchase-document-parse.debug';
import { extractJsonFromText } from './purchase-document-parse.normalizer';
import type { ParseDocumentInput } from './purchase-document-parse.types';

const DEFAULT_MODEL = 'gemini-flash-latest';
const FALLBACK_MODELS = ['gemini-flash-latest', 'gemini-2.5-flash'] as const;
const GEMINI_REQUEST_TIMEOUT_MS = 120_000;

const PURCHASE_INVOICE_EXTRACTION_PROMPT = `You are an expert Indian purchase invoice OCR assistant.

Extract purchase bill / supplier invoice details from the attached document image or PDF.

Rules:
- Return ONLY valid JSON. No markdown, no commentary.
- Use null for any field that is missing or unreadable. Do not guess.
- Dates must be YYYY-MM-DD when known.
- Numbers must be plain JSON numbers without currency symbols.
- payment_mode must be one of: cash, upi, cheque, bank_transfer, card, other, or null.
- tax_rate on each line is total GST percentage (e.g. 18 for 18% GST).
- tax_amount on each line is the GST amount printed on the bill for that line.
- tax_inclusive is true only when unit_price already includes GST.
- Include only line items that have a readable item/product name.
- For Indian GST invoices, vendor_name is the supplier/seller name.
- vendor_phone, vendor_email, vendor_address, vendor_city, vendor_pincode, and vendor_state are the supplier's contact/address details from the bill header (not the buyer).

JSON schema:
{
  "vendor_name": string | null,
  "gstin": string | null,
  "vendor_phone": string | null,
  "vendor_email": string | null,
  "vendor_address": string | null,
  "vendor_city": string | null,
  "vendor_pincode": string | null,
  "vendor_state": string | null,
  "supplier_invoice_number": string | null,
  "invoice_number": string | null,
  "invoice_date": string | null,
  "due_date": string | null,
  "state_of_supply": string | null,
  "payment_mode": string | null,
  "payment_amount": number | null,
  "notes": string | null,
  "terms_notes": string | null,
  "subtotal": number | null,
  "discount_total": number | null,
  "tax_amount": number | null,
  "total_amount": number | null,
  "lines": [
    {
      "item_name": string,
      "description": string | null,
      "quantity": number | null,
      "unit": string | null,
      "unit_price": number | null,
      "tax_rate": number | null,
      "tax_inclusive": boolean | null,
      "tax_amount": number | null,
      "discount_amount": number | null
    }
  ]
}`;

function mimeTypeFor(input: ParseDocumentInput): string {
  const fromHeader = input.mimeType?.toLowerCase();
  if (fromHeader && fromHeader !== 'application/octet-stream') {
    return fromHeader;
  }

  const extension = input.filename.toLowerCase().split('.').pop() ?? '';
  switch (extension) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'pdf':
      return 'application/pdf';
    default:
      return 'application/octet-stream';
  }
}

function normalizeModelId(value: string): string {
  return value.trim().replace(/^models\//, '');
}

/** Picks a supported Gemini model; remaps deprecated 1.5 IDs to gemini-flash-latest. */
export function resolveGeminiModel(): string {
  const configured = process.env.GEMINI_MODEL?.trim();
  if (!configured) return DEFAULT_MODEL;

  const model = normalizeModelId(configured);
  if (model.includes('1.5')) {
    return DEFAULT_MODEL;
  }

  return model;
}

function modelsToTry(): string[] {
  const preferred = resolveGeminiModel();
  return [...new Set([preferred, ...FALLBACK_MODELS])];
}

function isModelAvailabilityError(message: string): boolean {
  const lower = message.toLowerCase();
  return (
    lower.includes('no longer available') ||
    lower.includes('not found') ||
    lower.includes('is not supported') ||
    lower.includes('does not exist')
  );
}

function isAuthError(message: string): boolean {
  const lower = message.toLowerCase();
  return (
    lower.includes('api key not valid') ||
    lower.includes('invalid authentication') ||
    lower.includes('oauth') ||
    lower.includes('unauthenticated') ||
    lower.includes('permission denied')
  );
}

function mapGeminiError(error: unknown): AppError {
  const message =
    error instanceof Error
      ? error.message
      : 'Gemini failed to parse the document';

  if (message.toLowerCase().includes('timeout')) {
    return new AppError(
      'PARSE_FAILED',
      'Document parsing timed out. Try a smaller file or retry.',
      504,
    );
  }

  if (isAuthError(message)) {
    return new AppError(
      'PARSE_FAILED',
      'Invalid Gemini API key. Use a Google AI Studio key (https://aistudio.google.com/apikey), not Vertex AI or OAuth credentials.',
      502,
    );
  }

  return new AppError('PARSE_FAILED', message, 502);
}

async function requestGemini(
  model: string,
  mimeType: string,
  base64Data: string,
): Promise<unknown> {
  const client = getGeminiDeveloperClient();

  logGeminiRequestStart(model);

  const startedAt = logGeminiGenerateContentStart(model);

  let response: { text?: string | null };
  try {
    response = await client.models.generateContent({
      model,
      contents: [
        {
          inlineData: {
            mimeType,
            data: base64Data,
          },
        },
        { text: PURCHASE_INVOICE_EXTRACTION_PROMPT },
      ],
      config: {
        temperature: 0.1,
        responseMimeType: 'application/json',
        httpOptions: {
          timeout: GEMINI_REQUEST_TIMEOUT_MS,
        },
      },
    });
  } catch (error) {
    logGeminiGenerateContentEnd(model, startedAt);
    logGeminiApiError(error);
    throw error;
  }

  logGeminiGenerateContentEnd(model, startedAt);

  const text = response.text?.trim();
  logGeminiRawResponseText(text);

  if (!text) {
    throw new AppError(
      'PARSE_FAILED',
      'Gemini did not return any extracted invoice data',
      502,
    );
  }

  let parsed: unknown;
  try {
    parsed = extractJsonFromText(text);
  } catch (error) {
    logJsonParseError('extractJsonFromText', error, text);
    throw error;
  }

  logGeminiParsedJson(parsed);
  return parsed;
}

export async function parsePurchaseDocumentWithGemini(
  input: ParseDocumentInput,
): Promise<unknown> {
  try {
    requireGeminiApiKey();
  } catch (error) {
    const message =
      error instanceof Error
        ? error.message
        : 'Gemini API key is not configured on the server';
    throw new AppError('PARSE_SERVICE_UNAVAILABLE', message, 503);
  }

  const mimeType = mimeTypeFor(input);
  const base64Data = input.buffer.toString('base64');
  const candidates = modelsToTry();
  let lastError: AppError | null = null;

  for (const model of candidates) {
    try {
      return await requestGemini(model, mimeType, base64Data);
    } catch (error) {
      const mapped = error instanceof AppError ? error : mapGeminiError(error);

      if (mapped.code !== 'PARSE_FAILED') {
        throw mapped;
      }

      lastError = mapped;
      if (!isModelAvailabilityError(mapped.message)) {
        throw mapped;
      }
    }
  }

  throw (
    lastError ??
    new AppError('PARSE_FAILED', 'Gemini failed to parse the document', 502)
  );
}
