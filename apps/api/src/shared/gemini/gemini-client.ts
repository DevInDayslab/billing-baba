import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { dirname, join } from 'node:path';
import type { GoogleGenAI } from '@google/genai' with { 'resolution-mode': 'import' };

const resolveFromHere = createRequire(__filename);

// @google/genai is ESM; load the package CJS build under Node16 CommonJS.
const { GoogleGenAI: GoogleGenAIConstructor } = resolveFromHere(
  '@google/genai',
) as {
  GoogleGenAI: new (options: {
    apiKey: string;
    vertexai: boolean;
  }) => GoogleGenAI;
};

function readGoogleGenAiSdkVersion(): string {
  try {
    const entry = resolveFromHere.resolve('@google/genai');
    let dir = dirname(entry);

    for (let depth = 0; depth < 5; depth += 1) {
      try {
        const pkg = JSON.parse(
          readFileSync(join(dir, 'package.json'), 'utf8'),
        ) as { name?: string; version?: string };

        if (pkg.name === '@google/genai' && pkg.version) {
          return pkg.version;
        }
      } catch {
        // Keep walking up until the package root is found.
      }

      dir = dirname(dir);
    }
  } catch {
    // Fall back when the SDK is not installed (e.g. partial test env).
  }

  return 'unknown';
}

export const GOOGLE_GENAI_SDK_VERSION = readGoogleGenAiSdkVersion();

const AI_STUDIO_KEY_HINT =
  'Create a free API key at https://aistudio.google.com/apikey (not Vertex AI or OAuth).';

const GEMINI_DEVELOPER_API_HOST = 'generativelanguage.googleapis.com';

/** Google AI Studio key family shown in startup / request logs. */
export type GeminiKeyType = 'Auth' | 'Standard' | 'Unknown';

/** Non-secret summary for startup logs. */
export type GeminiKeyDiagnostics = {
  loaded: boolean;
  keyType: GeminiKeyType | null;
  prefix: string | null;
  length: number | null;
  loadedSuccessfully: boolean;
  issue: string | null;
};

export type GeminiAuthEnvironmentAudit = {
  sdkVersion: string;
  conflictingEnvVars: string[];
  proxyConfigured: boolean;
};

function readGeminiApiKey(): string | null {
  const key = process.env.GEMINI_API_KEY?.trim();
  return key || null;
}

function classifyGeminiKeyType(key: string): GeminiKeyType {
  if (key.startsWith('AQ.')) {
    return 'Auth';
  }
  if (key.startsWith('AIza')) {
    return 'Standard';
  }
  return 'Unknown';
}

function validateGeminiApiKey(key: string): string | null {
  if (key.startsWith('ya29.')) {
    return (
      'GEMINI_API_KEY looks like an OAuth 2 access token, not a Google AI Studio API key. ' +
      AI_STUDIO_KEY_HINT
    );
  }

  if (key.startsWith('Bearer ')) {
    return (
      'GEMINI_API_KEY must be the raw key value, not a Bearer authorization header. ' +
      AI_STUDIO_KEY_HINT
    );
  }

  return null;
}

function maskHeaderValue(name: string, value: string): string {
  const lower = name.toLowerCase();

  if (lower === 'x-goog-api-key') {
    return `<present len=${value.length} prefix=${value.slice(0, 4)}…>`;
  }

  if (lower === 'authorization') {
    const bearer = value.toLowerCase().startsWith('bearer ');
    return `<present bearer=${bearer} len=${value.length}>`;
  }

  return value;
}

function maskOutgoingHeaders(
  headers: RequestInit['headers'],
): Record<string, string> {
  const masked: Record<string, string> = {};
  if (!headers) {
    return masked;
  }

  const pairs: [string, string][] =
    headers instanceof Headers
      ? (() => {
          const entries: [string, string][] = [];
          headers.forEach((value, key) => entries.push([key, value]));
          return entries;
        })()
      : Array.isArray(headers)
        ? headers.filter((entry): entry is [string, string] => entry[1] !== undefined)
        : Object.entries(headers).filter(
            (entry): entry is [string, string] => entry[1] !== undefined,
          );

  for (const [name, value] of pairs) {
    masked[name] = maskHeaderValue(name, value);
  }

  return masked;
}

function sanitizeGeminiUrl(url: string): string {
  try {
    const parsed = new URL(url);
    if (parsed.searchParams.has('key')) {
      parsed.searchParams.set('key', '<redacted>');
    }
    return parsed.toString();
  } catch {
    return url;
  }
}

/** Flags env vars that could alter SDK auth if misconfigured. */
export function auditGeminiAuthEnvironment(): GeminiAuthEnvironmentAudit {
  const conflictingEnvVars: string[] = [];

  if (process.env.GOOGLE_GENAI_ACCESS_TOKEN?.trim()) {
    conflictingEnvVars.push('GOOGLE_GENAI_ACCESS_TOKEN');
  }
  if (process.env.GOOGLE_GENAI_USE_VERTEXAI?.trim()) {
    conflictingEnvVars.push('GOOGLE_GENAI_USE_VERTEXAI');
  }
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS?.trim()) {
    conflictingEnvVars.push('GOOGLE_APPLICATION_CREDENTIALS');
  }
  if (process.env.GCLOUD_PROJECT?.trim() && !process.env.GEMINI_API_KEY?.trim()) {
    conflictingEnvVars.push('GCLOUD_PROJECT (without GEMINI_API_KEY)');
  }

  const proxyConfigured = Boolean(
    process.env.HTTP_PROXY?.trim() ||
      process.env.HTTPS_PROXY?.trim() ||
      process.env.http_proxy?.trim() ||
      process.env.https_proxy?.trim(),
  );

  return {
    sdkVersion: GOOGLE_GENAI_SDK_VERSION,
    conflictingEnvVars,
    proxyConfigured,
  };
}

export function formatGeminiAuthEnvironmentLogLine(
  audit: GeminiAuthEnvironmentAudit,
): string {
  const conflicts =
    audit.conflictingEnvVars.length > 0
      ? audit.conflictingEnvVars.join(', ')
      : 'none';

  return (
    `Gemini SDK @google/genai@${audit.sdkVersion} | auth env conflicts: ${conflicts} | ` +
    `proxy: ${audit.proxyConfigured ? 'configured' : 'none'}`
  );
}

export function describeGeminiKeyForLog(): GeminiKeyDiagnostics {
  const key = readGeminiApiKey();
  if (!key) {
    return {
      loaded: false,
      keyType: null,
      prefix: null,
      length: null,
      loadedSuccessfully: false,
      issue: `GEMINI_API_KEY is missing. ${AI_STUDIO_KEY_HINT}`,
    };
  }

  const issue = validateGeminiApiKey(key);

  return {
    loaded: true,
    keyType: classifyGeminiKeyType(key),
    prefix: key.slice(0, 4),
    length: key.length,
    loadedSuccessfully: issue === null,
    issue,
  };
}

export function formatGeminiKeyLogLine(diagnostics: GeminiKeyDiagnostics): string {
  if (!diagnostics.loaded) {
    return 'Gemini Developer API: key not loaded';
  }

  if (!diagnostics.loadedSuccessfully) {
    return (
      `Gemini Developer API: key rejected | type=${diagnostics.keyType} | ` +
      `prefix=${diagnostics.prefix}… | length=${diagnostics.length}`
    );
  }

  return (
    `Gemini Developer API: key loaded successfully | type=${diagnostics.keyType} | ` +
    `prefix=${diagnostics.prefix}… | length=${diagnostics.length}`
  );
}

export function requireGeminiApiKey(): string {
  const key = readGeminiApiKey();
  if (!key) {
    throw new Error(
      `GEMINI_API_KEY is not configured on the server. ${AI_STUDIO_KEY_HINT}`,
    );
  }

  const issue = validateGeminiApiKey(key);
  if (issue) {
    throw new Error(issue);
  }

  return key;
}

/** Logs model and masked key metadata immediately before a Gemini HTTP call. */
export function logGeminiRequestStart(model: string): void {
  const diagnostics = describeGeminiKeyForLog();
  const prefix = diagnostics.prefix ? `${diagnostics.prefix}…` : 'unknown';
  const keyType = diagnostics.keyType ?? 'Unknown';

  console.info(
    `[Gemini] Request: sdk=@google/genai@${GOOGLE_GENAI_SDK_VERSION} model=${model} ` +
      `keyType=${keyType} keyPrefix=${prefix}`,
  );
}

/** Logs SDK error metadata when the HTTP layer does not surface a body. */
export function logGeminiApiError(error: unknown): void {
  if (!error || typeof error !== 'object') {
    return;
  }

  const status =
    'status' in error && typeof error.status === 'number' ? error.status : null;

  if (status !== null && status >= 400) {
    const message = error instanceof Error ? error.message : String(error);
    console.error(`[Gemini] API error: status=${status} message=${message}`);
  }
}

let cachedClient: GoogleGenAI | null = null;
let cachedClientKey: string | null = null;
let fetchLoggingInstalled = false;

function logOutgoingGeminiRequest(
  url: string,
  init: RequestInit | undefined,
): void {
  const maskedHeaders = maskOutgoingHeaders(init?.headers);
  const headerNames = Object.keys(maskedHeaders).map((name) => name.toLowerCase());
  const hasApiKeyHeader = headerNames.includes('x-goog-api-key');
  const hasAuthorizationHeader = headerNames.includes('authorization');

  let queryKeyParam = false;
  try {
    queryKeyParam = new URL(url).searchParams.has('key');
  } catch {
    // ignore malformed URLs
  }

  console.info(
    `[Gemini] Outgoing headers: ${JSON.stringify(maskedHeaders)} | ` +
      `x-goog-api-key=${hasApiKeyHeader} authorization=${hasAuthorizationHeader} ` +
      `queryKeyParam=${queryKeyParam}`,
  );

  if (hasAuthorizationHeader) {
    console.warn(
      '[Gemini] Unexpected Authorization header on Developer API request — ' +
        'AQ/AIza keys must use x-goog-api-key only.',
    );
  }

  if (queryKeyParam) {
    console.warn(
      '[Gemini] API key present in URL query string — Developer API should use x-goog-api-key header only.',
    );
  }

  console.info(
    `[Gemini] Outgoing request: method=${init?.method ?? 'GET'} url=${sanitizeGeminiUrl(url)}`,
  );
}

function installGeminiFetchLogging(): void {
  if (fetchLoggingInstalled || typeof globalThis.fetch !== 'function') {
    return;
  }

  fetchLoggingInstalled = true;
  const originalFetch = globalThis.fetch.bind(globalThis);

  globalThis.fetch = async (input, init) => {
    const url =
      typeof input === 'string'
        ? input
        : input instanceof URL
          ? input.href
          : input.url;

    if (url.includes(GEMINI_DEVELOPER_API_HOST)) {
      logOutgoingGeminiRequest(url, init);
    }

    const response = await originalFetch(input, init);

    if (url.includes(GEMINI_DEVELOPER_API_HOST) && !response.ok) {
      const body = await response.clone().text();
      console.error(
        `[Gemini] HTTP response: status=${response.status} statusText=${response.statusText} body=${body}`,
      );
    }

    return response;
  };
}

/** Gemini Developer API client (API key only — not Vertex AI). */
export function getGeminiDeveloperClient(): GoogleGenAI {
  const apiKey = requireGeminiApiKey();

  if (cachedClient && cachedClientKey === apiKey) {
    return cachedClient;
  }

  installGeminiFetchLogging();

  cachedClient = new GoogleGenAIConstructor({
    apiKey,
    // Explicitly use Gemini Developer API; never Vertex OAuth/project auth.
    vertexai: false,
  });
  cachedClientKey = apiKey;

  return cachedClient;
}

export function resetGeminiClientForTests(): void {
  cachedClient = null;
  cachedClientKey = null;
}
