import 'dotenv/config';
import { migrate } from 'drizzle-orm/postgres-js/migrator';
import postgres from 'postgres';
import { drizzle } from 'drizzle-orm/postgres-js';

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  throw new Error('DATABASE_URL is not set');
}

const migrationClient = postgres(connectionString, { max: 1, prepare: false });
const db = drizzle(migrationClient);

async function runMigrations() {
  console.log('Running migrations...');
  await migrate(db, { migrationsFolder: './drizzle/migrations' });
  console.log('Migrations complete');
  await migrationClient.end();
}

runMigrations().catch((error) => {
  console.error('Migration failed:', error);
  process.exit(1);
});
