import 'dotenv/config';
import { getDb } from './client';
import {
  businesses,
  businessSettings,
  documentNumberSequences,
  expenseCategories,
  godowns,
  schemaVersion,
} from './schema';

async function seed() {
  const db = getDb();
  if (!db) {
    throw new Error('DATABASE_URL is not set');
  }

  console.log('Seeding development data...');

  const [business] = await db
    .insert(businesses)
    .values({
      name: 'Demo Shop',
      stateCode: '27',
      gstin: '27AAAAA0000A1Z5',
      valuationMethod: 'average',
    })
    .returning();

  if (!business) {
    throw new Error('Failed to create business');
  }

  await db.insert(businessSettings).values({
    businessId: business.id,
    valuationMethod: 'average',
    defaultTaxType: 'none',
    enablePriceConflictAlerts: true,
    creditLimitAction: 'warn',
  });

  await db.insert(godowns).values({
    businessId: business.id,
    name: 'Main Warehouse',
    isDefault: true,
  });

  await db.insert(documentNumberSequences).values({
    businessId: business.id,
    documentSeries: 'INV',
    prefix: 'INV',
    nextNumber: 1,
    fiscalYear: '2026',
  });

  await db.insert(expenseCategories).values([
    { businessId: business.id, name: 'Rent', isSystem: true },
    { businessId: business.id, name: 'Utilities', isSystem: true },
    { businessId: business.id, name: 'Salaries', isSystem: true },
  ]);

  await db.insert(schemaVersion).values({ version: 1 }).onConflictDoNothing();

  console.log('Seed complete for business:', business.id);
}

seed()
  .catch((error) => {
    console.error('Seed failed:', error);
    process.exit(1);
  })
  .finally(async () => {
    process.exit(0);
  });
