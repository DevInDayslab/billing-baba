import { sql } from 'drizzle-orm';
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import type { DatabaseHealthStatus } from '../shared/types';
import * as schema from './schema';

let queryClient: postgres.Sql | null = null;
let db: ReturnType<typeof drizzle<typeof schema>> | null = null;

const TRANSIENT_ERROR_CODES = new Set([
  'CONNECTION_CLOSED',
  'ECONNRESET',
  'ECONNREFUSED',
  'ETIMEDOUT',
  '57P01',
  '08000',
  '08003',
  '08006',
  '08001',
  '53300',
]);

function delay(ms: number): Promise<void> {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}

function isLocalDatabase(connectionString: string): boolean {
  return /localhost|127\.0\.0\.1/.test(connectionString);
}

function createPostgresOptions(
  connectionString: string,
): postgres.Options<Record<string, never>> {
  const options: postgres.Options<Record<string, never>> = {
    // Neon pooler: serverless endpoints reject prepared statements.
    prepare: false,
    max: 10,
    // Recycle connections before Neon/pooler drops idle sockets.
    idle_timeout: 20,
    max_lifetime: 60 * 10,
    connect_timeout: 30,
    connection: {
      application_name: 'billing-baba-api',
    },
  };

  if (!isLocalDatabase(connectionString)) {
    options.ssl = 'require';
  }

  return options;
}

function collectErrorChain(error: unknown): unknown[] {
  const chain: unknown[] = [];
  let current: unknown = error;

  while (current && chain.length < 6) {
    chain.push(current);
    if (typeof current === 'object' && current !== null && 'cause' in current) {
      current = (current as { cause?: unknown }).cause;
      continue;
    }
    break;
  }

  return chain;
}

export function isTransientDatabaseError(error: unknown): boolean {
  return collectErrorChain(error).some((entry) => {
    if (!entry || typeof entry !== 'object') {
      return false;
    }

    const record = entry as Record<string, unknown>;
    const code = String(record.code ?? record.errno ?? '');
    const message = String(record.message ?? '');

    if (TRANSIENT_ERROR_CODES.has(code)) {
      return true;
    }

    return (
      message.includes('CONNECTION_CLOSED') ||
      message.includes('Connection terminated') ||
      message.includes('connection closed') ||
      message.includes('Client has encountered a connection error')
    );
  });
}

export async function resetDatabaseConnection(): Promise<void> {
  if (queryClient) {
    const client = queryClient;
    queryClient = null;
    db = null;
    try {
      await client.end({ timeout: 5 });
    } catch {
      // Pool may already be closed.
    }
    return;
  }

  db = null;
}

export async function withDatabaseRetry<T>(
  operation: () => Promise<T>,
  maxAttempts = 3,
): Promise<T> {
  let lastError: unknown;

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await operation();
    } catch (error) {
      lastError = error;
      if (!isTransientDatabaseError(error) || attempt === maxAttempts) {
        throw error;
      }

      await resetDatabaseConnection();
      await delay(attempt * 150);
    }
  }

  throw lastError;
}

function wrapPostgresQuery<T extends object>(query: T): T {
  return new Proxy(query, {
    get(target, prop, receiver) {
      const value = Reflect.get(target, prop, receiver);

      if (prop === 'then' && typeof value === 'function') {
        return (
          onFulfilled?: ((value: unknown) => unknown) | null,
          onRejected?: ((reason: unknown) => unknown) | null,
        ) =>
          withDatabaseRetry(() =>
            Promise.resolve(target).then(onFulfilled, onRejected),
          );
      }

      if (typeof value === 'function') {
        return (...args: unknown[]) => {
          const result = Reflect.apply(value, target, args);
          if (result && typeof result === 'object') {
            return wrapPostgresQuery(result);
          }
          return result;
        };
      }

      return value;
    },
  }) as T;
}

const NON_RETRIABLE_CLIENT_METHODS = new Set([
  'end',
  'file',
  'begin',
  'reserve',
  'listen',
  'notify',
  'subscribe',
]);

function createQueryClient(connectionString: string): postgres.Sql {
  const base = postgres(
    connectionString,
    createPostgresOptions(connectionString),
  );

  return new Proxy(base, {
    apply(target, thisArg, args) {
      return withDatabaseRetry(() => Reflect.apply(target, thisArg, args));
    },
    get(target, prop, receiver) {
      const value = Reflect.get(target, prop, receiver);
      if (typeof value !== 'function') {
        return value;
      }

      if (NON_RETRIABLE_CLIENT_METHODS.has(String(prop))) {
        return value.bind(target);
      }

      if (prop === 'unsafe') {
        return (...args: unknown[]) => {
          const result = Reflect.apply(value, target, args);
          if (result && typeof result === 'object') {
            return wrapPostgresQuery(result);
          }
          return result;
        };
      }

      return (...args: unknown[]) =>
        withDatabaseRetry(
          () => Reflect.apply(value, target, args) as Promise<unknown>,
        );
    },
  }) as postgres.Sql;
}

function getQueryClient(connectionString: string): postgres.Sql {
  if (!queryClient) {
    queryClient = createQueryClient(connectionString);
  }

  return queryClient;
}

export function isDatabaseConfigured(): boolean {
  return Boolean(process.env.DATABASE_URL);
}

export function getDb(): ReturnType<typeof drizzle<typeof schema>> | null {
  const connectionString = process.env.DATABASE_URL;
  if (!connectionString) {
    return null;
  }

  if (!db) {
    db = drizzle(getQueryClient(connectionString), { schema });
  }

  return db;
}

export async function checkDatabaseHealth(): Promise<DatabaseHealthStatus> {
  if (!isDatabaseConfigured()) {
    return 'not_configured';
  }

  try {
    await withDatabaseRetry(async () => {
      const database = getDb();
      if (!database) {
        throw new Error('DATABASE_URL is not set');
      }

      await database.execute(sql`SELECT 1`);
    });
    return 'connected';
  } catch {
    await resetDatabaseConnection();
    return 'disconnected';
  }
}

export async function closeDatabase(): Promise<void> {
  await resetDatabaseConnection();
}

export type Database = NonNullable<ReturnType<typeof getDb>>;
