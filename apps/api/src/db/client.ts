import { sql } from 'drizzle-orm';
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from './schema';

let queryClient: postgres.Sql | null = null;
let db: ReturnType<typeof drizzle<typeof schema>> | null = null;

function getQueryClient(): postgres.Sql | null {
  const connectionString = process.env.DATABASE_URL;
  if (!connectionString) {
    return null;
  }

  if (!queryClient) {
    // NeonDB: disable prepared statements for serverless pooler compatibility.
    queryClient = postgres(connectionString, { prepare: false });
  }

  return queryClient;
}

export function getDb(): ReturnType<typeof drizzle<typeof schema>> | null {
  const client = getQueryClient();
  if (!client) {
    return null;
  }

  if (!db) {
    db = drizzle(client, { schema });
  }

  return db;
}

export async function checkDatabaseConnection(): Promise<boolean> {
  try {
    const database = getDb();
    if (!database) {
      return false;
    }

    await database.execute(sql`SELECT 1`);
    return true;
  } catch {
    return false;
  }
}

export type Database = NonNullable<ReturnType<typeof getDb>>;
