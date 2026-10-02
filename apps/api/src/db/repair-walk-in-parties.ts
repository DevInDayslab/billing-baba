import 'dotenv/config';
import { eq } from 'drizzle-orm';
import { seedWalkInPartyForBusiness } from '../shared/parties/walk-in-party';
import { getDb } from './client';
import { businesses } from './schema/business/tables';

/**
 * One-time repair: seed walk-in customer party for every business.
 * Run: bun src/db/repair-walk-in-parties.ts
 */
async function main() {
  const db = getDb();
  if (!db) {
    throw new Error('DATABASE_URL is not configured');
  }

  const rows = await db
    .select({ id: businesses.id, name: businesses.name })
    .from(businesses)
    .where(eq(businesses.isDeleted, false));

  for (const business of rows) {
    await seedWalkInPartyForBusiness(db, business.id);
    console.log(`Seeded walk-in party for ${business.name} (${business.id})`);
  }

  console.log(`Done. ${rows.length} business(es) processed.`);
  process.exit(0);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
