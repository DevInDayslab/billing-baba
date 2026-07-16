/**
 * One-shot Gemini trace — writes evidence to gemini-trace-evidence.json
 * Run: node scripts/gemini-trace.mjs
 */

import { writeFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { config as loadEnv } from 'dotenv';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
loadEnv({ path: path.resolve(__dirname, '../.env'), override: true });

const require = createRequire(import.meta.url);
const { GoogleGenAI } = require('@google/genai');

const rawKey = process.env.GEMINI_API_KEY ?? '';
const trace = {
  env: {
    bracketed: `[${process.env.GEMINI_API_KEY}]`,
    first5: rawKey.slice(0, 5),
    last5: rawKey.slice(-5),
    length: rawKey.length,
    hasSpacesQuotesNewlinesOrBearer:
      /\s/.test(rawKey) ||
      /["']/.test(rawKey) ||
      /[\r\n]/.test(rawKey) ||
      /bearer/i.test(rawKey),
    trimmedLength: rawKey.trim().length,
  },
  prefixValidation: null,
  sdkVersion: require('../node_modules/@google/genai/package.json').version,
  requests: [],
  sdkError: null,
  conclusion: null,
};

// Mirror app requireGeminiApiKey / describeGeminiKeyForLog logic
function looksLikeAiStudioApiKey(key) {
  if (key.startsWith('AIza') && key.length >= 35) return true;
  if (
    key.startsWith('AQ.') ||
    key.startsWith('ya29.') ||
    key.startsWith('Bearer ')
  )
    return false;
  return key.length >= 20 && /^[A-Za-z0-9_-]+$/.test(key);
}

const trimmed = rawKey.trim();
let issue = null;
if (!trimmed) issue = 'GEMINI_API_KEY missing';
else if (trimmed.startsWith('AQ.') || trimmed.startsWith('ya29.'))
  issue = 'GEMINI_API_KEY looks like OAuth/Vertex token (app validation)';
else if (!looksLikeAiStudioApiKey(trimmed))
  issue = 'GEMINI_API_KEY unusual format (app validation)';

trace.prefixValidation = {
  looksLikeAiStudioApiKey: looksLikeAiStudioApiKey(trimmed),
  issue,
};

function maskHeaders(headers) {
  const out = {};
  if (!headers) return out;
  const pairs =
    headers instanceof Headers
      ? Array.from(headers.entries())
      : Array.isArray(headers)
        ? headers
        : Object.entries(headers);
  for (const [k, v] of pairs) {
    if (k.toLowerCase() === 'x-goog-api-key') {
      out[k] = `<masked len=${String(v).length}>`;
    } else if (k.toLowerCase() === 'authorization') {
      out[k] =
        `<masked bearer=${String(v).toLowerCase().startsWith('bearer ')}>`;
    } else {
      out[k] = v;
    }
  }
  return out;
}

const originalFetch = globalThis.fetch.bind(globalThis);
globalThis.fetch = async (input, init) => {
  const url =
    typeof input === 'string'
      ? input
      : input instanceof URL
        ? input.href
        : input.url;
  let bodyText = null;
  if (init?.body) {
    bodyText =
      typeof init.body === 'string'
        ? init.body
        : Buffer.isBuffer(init.body)
          ? init.body.toString('utf8')
          : String(init.body);
  }

  const entry = {
    url,
    method: init?.method ?? 'GET',
    requestHeaders: maskHeaders(init?.headers),
    requestBody: bodyText,
    responseStatus: null,
    responseBody: null,
  };

  try {
    const response = await originalFetch(input, init);
    entry.responseStatus = response.status;
    entry.responseBody = await response.clone().text();
    trace.requests.push(entry);
    return response;
  } catch (error) {
    entry.fetchError = error instanceof Error ? error.message : String(error);
    trace.requests.push(entry);
    throw error;
  }
};

async function main() {
  if (issue) {
    trace.conclusion = `Stopped before SDK call: app prefix validation failed — ${issue}`;
    writeFileSync(
      path.resolve(__dirname, '../gemini-trace-evidence.json'),
      JSON.stringify(trace, null, 2),
    );
    console.log(
      'Trace written (no HTTP request made). See gemini-trace-evidence.json',
    );
    return;
  }

  const client = new GoogleGenAI({
    apiKey: process.env.GEMINI_API_KEY,
    vertexai: false,
  });
  const model = process.env.GEMINI_MODEL?.trim() || 'gemini-flash-latest';

  // 1x1 red PNG
  const pngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

  try {
    await client.models.generateContent({
      model,
      contents: [
        { inlineData: { mimeType: 'image/png', data: pngBase64 } },
        { text: 'Return JSON: {"ok":true}' },
      ],
      config: {
        temperature: 0.1,
        responseMimeType: 'application/json',
      },
    });
    trace.conclusion = 'SDK call completed without throw';
  } catch (error) {
    trace.sdkError = {
      message: error instanceof Error ? error.message : String(error),
      status: error?.status ?? null,
      cause: error?.cause ?? null,
      stack: error instanceof Error ? error.stack : null,
      response: error?.response ?? null,
      error: error?.error ?? null,
    };
    trace.conclusion = 'SDK threw — see requests[] for HTTP evidence';
  }

  writeFileSync(
    path.resolve(__dirname, '../gemini-trace-evidence.json'),
    JSON.stringify(trace, null, 2),
  );
  console.log('Trace written to gemini-trace-evidence.json');
}

main();
