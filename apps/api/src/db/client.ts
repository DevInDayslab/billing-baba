import { sql } from 'drizzle-orm';
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import type { DatabaseHealthStatus } from '../shared/types';
import * as schema from './schema';

let queryClient: postgres.Sql | null = null;
let db: ReturnType<typeof drizzle<typeof schema>> | null = null;

function getQueryClient(connectionString: string): postgres.Sql {
  if (!queryClient) {
    // Neon: disable prepared statements for serverless pooler compatibility.
    queryClient = postgres(connectionString, { prepare: false });
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
    const database = getDb();
    if (!database) {
      return 'not_configured';
    }

    await database.execute(sql`SELECT 1`);
    return 'connected';
  } catch {
    return 'disconnected';
  }
}

export async function closeDatabase(): Promise<void> {
  if (queryClient) {
    await queryClient.end();
    queryClient = null;
    db = null;
  }
}

export type Database = NonNullable<ReturnType<typeof getDb>>;
