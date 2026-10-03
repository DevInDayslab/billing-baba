import 'dotenv/config';
import { eq } from 'drizzle-orm';
import { loadAppConfig } from '../src/config/app_config';
import { getDb } from '../src/db/client';
import { itemLocationHistory } from '../src/db/schema/inventory/tables';
import { ItemLocationHistoryRepository } from '../src/modules/inventory/item-location-history.repository';
import { StorageService } from '../src/modules/storage/storage.service';

/** Dev helper: seed rack photo history for manual UI testing. */
const BUSINESS_ID = 'b234a35a-f0b1-4fcc-915b-dbf2c46328fa';
const ITEM_ID = '01d72fda-73bf-474b-9165-a4a0816b8548';
const LOCATION_ID = '48c23e83-cf89-43b1-85e6-a13378ed5ca4';

/** Current rack photo asset on the test location (re-signed for unique history URLs). */
const SEED_ASSET_ID = '82515507-9a22-41e0-91c3-9dd3c5857c72';

const RACK_LABELS = ['A1', 'A2', 'A3', 'A4', 'A5'] as const;

async function main() {
  const db = getDb();
  if (!db) {
    throw new Error('DATABASE_URL is not configured');
  }

  const config = loadAppConfig();
  const storage = new StorageService({ config });
  const history = new ItemLocationHistoryRepository(db);

  await db
    .delete(itemLocationHistory)
    .where(eq(itemLocationHistory.itemLocationId, LOCATION_ID));

  const photoUrls: string[] = [];
  for (let i = 0; i < 5; i++) {
    const { url } = await storage.getBusinessAssetDownloadUrl(
      BUSINESS_ID,
      SEED_ASSET_ID,
    );
    photoUrls.push(url);
    if (i < 4) {
      // Fresh signatures so URLs stay unique for the client deduper.
      await new Promise((resolve) => setTimeout(resolve, 1_100));
    }
  }

  for (let i = 0; i < 5; i++) {
    await history.insert({
      businessId: BUSINESS_ID,
      itemLocationId: LOCATION_ID,
      itemId: ITEM_ID,
      rack: RACK_LABELS[i],
      photoUrl: photoUrls[i],
      photoMediaAssetId: SEED_ASSET_ID,
      employeeLabel: `Seed tester ${i + 1}`,
    });
  }

  console.log(
    `Seeded 5 rack photo history rows for item ${ITEM_ID} (location ${LOCATION_ID}).`,
  );
  process.exit(0);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
