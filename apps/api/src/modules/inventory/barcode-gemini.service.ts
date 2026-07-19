import {
  getGeminiDeveloperClient,
  logGeminiApiError,
  logGeminiRequestStart,
} from '../../shared/gemini/gemini-client';

const DEFAULT_MODEL = 'gemini-3.1-flash-lite';
const GEMINI_REQUEST_TIMEOUT_MS = 30_000;

export interface BarcodeGeminiResult {
  found: boolean;
  itemName?: string;
  category?: string;
  hsnCode?: string;
  defaultMrp?: string;
  taxPercent?: string;
  baseUnit?: string;
  incTax?: boolean;
}

function buildBarcodeLookupPrompt(barcode: string): string {
  return `You are a barcode product database for Indian retail. You will be given a barcode number.

STRICT RULES:
- Only return product data if you are CERTAIN this exact barcode maps to a real product
- Indian retail barcodes (EAN-13 starting with 890) are common — only confirm if you 
  are certain of the exact SKU
- If you have ANY doubt, return { "found": false }
- Do NOT guess, infer, or use similar barcodes
- Do NOT return a product just because the barcode format looks valid
- For Indian products, defaultMrp is the standard Maximum Retail Price printed on the
  package in Indian Rupees (₹). Return it as a numeric string without the ₹ symbol.
  Example: "28" for Tata Salt 1kg. If unknown, return empty string.

Barcode: ${barcode}

If CERTAIN about the product identity: return ONLY this JSON:
{
  "found": true,
  "itemName": "exact product name with pack size if known",
  "category": "category",
  "hsnCode": "4 or 6 digit HSN/SAC code if certain, else empty string",
  "defaultMrp": "MRP in rupees as numeric string, or empty string if unknown",
  "taxPercent": "GST % as string if certain for this product category, else empty string",
  "baseUnit": "unit or empty string",
  "incTax": true
}

If NOT certain: return ONLY:
{ "found": false }

Return ONLY valid JSON. No explanation, no markdown, no preamble.`;
}

function extractJsonFromText(text: string): unknown {
  const trimmed = text.trim();
  if (!trimmed) {
    throw new Error('Gemini returned an empty response');
  }

  try {
    return JSON.parse(trimmed);
  } catch {
    const fenced = trimmed.match(/```(?:json)?\s*([\s\S]*?)```/i);
    if (fenced?.[1]) {
      return JSON.parse(fenced[1].trim());
    }

    const start = trimmed.indexOf('{');
    const end = trimmed.lastIndexOf('}');
    if (start >= 0 && end > start) {
      return JSON.parse(trimmed.slice(start, end + 1));
    }

    throw new Error('Gemini response did not contain valid JSON');
  }
}

function asOptionalString(value: unknown): string | undefined {
  if (value === null || value === undefined) return undefined;
  const str = String(value).trim();
  return str.length > 0 ? str : undefined;
}

function normalizeGeminiResult(parsed: unknown): BarcodeGeminiResult {
  if (typeof parsed !== 'object' || parsed === null) {
    return { found: false };
  }

  const record = parsed as Record<string, unknown>;
  if (record.found !== true) {
    return { found: false };
  }

  return {
    found: true,
    itemName: asOptionalString(record.itemName),
    category: asOptionalString(record.category),
    hsnCode: asOptionalString(record.hsnCode),
    defaultMrp: asOptionalString(record.defaultMrp),
    taxPercent: asOptionalString(record.taxPercent),
    baseUnit: asOptionalString(record.baseUnit),
    incTax: typeof record.incTax === 'boolean' ? record.incTax : undefined,
  };
}

function validateGeminiConfidence(result: BarcodeGeminiResult): BarcodeGeminiResult {
  if (result.found && result.itemName) {
    const name = result.itemName.toLowerCase().trim();
    if (name.length < 3) {
      return { found: false };
    }
  }

  if (result.found && !result.itemName?.trim()) {
    return { found: false };
  }

  return result;
}

function logGeminiLookupResult(
  barcode: string,
  result: BarcodeGeminiResult,
): void {
  console.log(
    `[Gemini] barcode=${barcode} found=${result.found} name=${result.itemName ?? 'N/A'}`,
  );
}

export class BarcodeGeminiService {
  async lookupBarcode(barcode: string): Promise<BarcodeGeminiResult> {
    try {
      const client = getGeminiDeveloperClient();
      const model = DEFAULT_MODEL;

      logGeminiRequestStart(model);

      const response = await client.models.generateContent({
        model,
        contents: [{ text: buildBarcodeLookupPrompt(barcode) }],
        config: {
          temperature: 0.1,
          responseMimeType: 'application/json',
          httpOptions: {
            timeout: GEMINI_REQUEST_TIMEOUT_MS,
          },
        },
      });

      const text = response.text?.trim();
      console.log('[BarcodeGemini] Raw response:', JSON.stringify(text));
      if (!text) {
        const result = { found: false };
        logGeminiLookupResult(barcode, result);
        return result;
      }

      const parsed = extractJsonFromText(text);
      const normalized = normalizeGeminiResult(parsed);
      const result = validateGeminiConfidence(normalized);
      logGeminiLookupResult(barcode, result);
      return result;
    } catch (error) {
      logGeminiApiError(error);
      const result = { found: false };
      logGeminiLookupResult(barcode, result);
      return result;
    }
  }
}
