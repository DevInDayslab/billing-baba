import 'dotenv/config';
import { getDb } from './client';
import { schemaVersion } from './schema/meta/tables';
import { seedDemoData } from './seed/demo-seeder';

async function seed() {
  const db = getDb();
  if (!db) {
    throw new Error('DATABASE_URL is not set');
  }

  console.log('Seeding realistic demo data...');
  await seedDemoData(db);
  await db.insert(schemaVersion).values({ version: 1 }).onConflictDoNothing();
}

seed()
  .catch((error) => {
    console.error('Seed failed:', error);
    process.exit(1);
  })
  .finally(async () => {
    process.exit(0);
  });
