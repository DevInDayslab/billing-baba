import 'dotenv/config';
import { eq } from 'drizzle-orm';
import { getDb } from '../src/db/client';
import {
  itemImages,
  itemLocationHistory,
  itemLocations,
  items,
} from '../src/db/schema/inventory/tables';

const ITEM_ID = '01d72fda-73bf-474b-9165-a4a0816b8548';

async function main() {
  const db = getDb();
  if (!db) throw new Error('DATABASE_URL is not configured');

  const locs = await db
    .select({ id: itemLocations.id })
    .from(itemLocations)
    .where(eq(itemLocations.itemId, ITEM_ID));

  for (const loc of locs) {
    await db
      .delete(itemLocationHistory)
      .where(eq(itemLocationHistory.itemLocationId, loc.id));
    await db
      .update(itemLocations)
      .set({
        photoUrl: null,
        photoMediaAssetId: null,
        photoTakenAt: null,
      })
      .where(eq(itemLocations.id, loc.id));
  }

  await db.delete(itemImages).where(eq(itemImages.itemId, ITEM_ID));

  await db
    .update(items)
    .set({ primaryImageUrl: null })
    .where(eq(items.id, ITEM_ID));

  console.log(
    `Cleared item gallery images and rack photos/history for item ${ITEM_ID} (${locs.length} location(s)).`,
  );
  process.exit(0);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
