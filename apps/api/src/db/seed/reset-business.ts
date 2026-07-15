import { eq, inArray } from 'drizzle-orm';
import type { Database } from '../client';
import {
  ledgerEntries,
  paymentAllocations,
  payments,
} from '../schema/accounting/tables';
import { branches } from '../schema/business/tables';
import {
  parties,
  partyAttachments,
  partyLinks,
  partyLoyaltyBalances,
  partyTagAssignments,
  partyTags,
  partyVisits,
} from '../schema/crm/tables';
import {
  attendanceRecords,
  devices,
  refreshTokens,
  users,
} from '../schema/identity/tables';
import {
  brands,
  categories,
  godowns,
  inventoryMovements,
  itemImages,
  itemLocations,
  itemPriceHistory,
  items,
  itemTierPrices,
  itemUnits,
  stockLevels,
  unitConversions,
  unitDefinitions,
} from '../schema/inventory/tables';
import {
  jobWorkAdditionalCosts,
  jobWorkOrders,
  jobWorkRawMaterialLines,
} from '../schema/job-work/tables';
import { alerts, todos } from '../schema/notifications/tables';
import {
  expenses,
  purchaseDocumentLines,
  purchaseDocuments,
  purchaseFaBatches,
  purchaseFixedAssets,
} from '../schema/purchases/tables';
import {
  posSessions,
  salesDocumentLines,
  salesDocuments,
} from '../schema/sales/tables';
import {
  areas,
  documentNumberSequences,
  loyaltyRules,
  taxRates,
} from '../schema/settings/tables';
import { onlineOrders } from '../schema/sync/tables';

/**
 * Removes all business-scoped data while keeping the business row and owner user.
 * Used before re-seeding demo data for development.
 */
export async function resetBusinessData(
  db: Database,
  businessId: string,
): Promise<void> {
  const userRows = await db
    .select({ id: users.id })
    .from(users)
    .where(eq(users.businessId, businessId));
  const userIds = userRows.map((row) => row.id);

  await db.transaction(async (tx) => {
    if (userIds.length > 0) {
      await tx
        .delete(refreshTokens)
        .where(inArray(refreshTokens.userId, userIds));
    }

    await tx
      .delete(paymentAllocations)
      .where(eq(paymentAllocations.businessId, businessId));
    await tx.delete(payments).where(eq(payments.businessId, businessId));
    await tx
      .delete(ledgerEntries)
      .where(eq(ledgerEntries.businessId, businessId));
    await tx
      .delete(inventoryMovements)
      .where(eq(inventoryMovements.businessId, businessId));
    await tx
      .delete(itemPriceHistory)
      .where(eq(itemPriceHistory.businessId, businessId));
    await tx
      .delete(salesDocumentLines)
      .where(eq(salesDocumentLines.businessId, businessId));
    await tx
      .delete(salesDocuments)
      .where(eq(salesDocuments.businessId, businessId));
    await tx.delete(posSessions).where(eq(posSessions.businessId, businessId));
    await tx
      .delete(purchaseDocumentLines)
      .where(eq(purchaseDocumentLines.businessId, businessId));
    await tx
      .delete(purchaseDocuments)
      .where(eq(purchaseDocuments.businessId, businessId));
    await tx
      .delete(purchaseFixedAssets)
      .where(eq(purchaseFixedAssets.businessId, businessId));
    await tx
      .delete(purchaseFaBatches)
      .where(eq(purchaseFaBatches.businessId, businessId));
    await tx.delete(expenses).where(eq(expenses.businessId, businessId));
    await tx
      .delete(jobWorkRawMaterialLines)
      .where(eq(jobWorkRawMaterialLines.businessId, businessId));
    await tx
      .delete(jobWorkAdditionalCosts)
      .where(eq(jobWorkAdditionalCosts.businessId, businessId));
    await tx
      .delete(jobWorkOrders)
      .where(eq(jobWorkOrders.businessId, businessId));
    await tx
      .delete(partyTagAssignments)
      .where(eq(partyTagAssignments.businessId, businessId));
    await tx
      .delete(partyLoyaltyBalances)
      .where(eq(partyLoyaltyBalances.businessId, businessId));
    await tx.delete(partyLinks).where(eq(partyLinks.businessId, businessId));
    await tx.delete(partyVisits).where(eq(partyVisits.businessId, businessId));
    await tx
      .delete(partyAttachments)
      .where(eq(partyAttachments.businessId, businessId));
    await tx.delete(parties).where(eq(parties.businessId, businessId));
    await tx.delete(partyTags).where(eq(partyTags.businessId, businessId));
    await tx.delete(stockLevels).where(eq(stockLevels.businessId, businessId));
    await tx
      .delete(itemLocations)
      .where(eq(itemLocations.businessId, businessId));
    await tx.delete(itemImages).where(eq(itemImages.businessId, businessId));
    await tx.delete(itemUnits).where(eq(itemUnits.businessId, businessId));
    await tx
      .delete(itemTierPrices)
      .where(eq(itemTierPrices.businessId, businessId));
    await tx.delete(items).where(eq(items.businessId, businessId));
    await tx
      .delete(unitConversions)
      .where(eq(unitConversions.businessId, businessId));
    await tx
      .delete(unitDefinitions)
      .where(eq(unitDefinitions.businessId, businessId));
    await tx.delete(brands).where(eq(brands.businessId, businessId));
    await tx.delete(categories).where(eq(categories.businessId, businessId));
    await tx.delete(godowns).where(eq(godowns.businessId, businessId));
    await tx.delete(alerts).where(eq(alerts.businessId, businessId));
    await tx.delete(todos).where(eq(todos.businessId, businessId));
    await tx
      .delete(onlineOrders)
      .where(eq(onlineOrders.businessId, businessId));
    await tx
      .delete(attendanceRecords)
      .where(eq(attendanceRecords.businessId, businessId));
    await tx.delete(devices).where(eq(devices.businessId, businessId));
    await tx.delete(areas).where(eq(areas.businessId, businessId));
    await tx.delete(branches).where(eq(branches.businessId, businessId));
    await tx.delete(taxRates).where(eq(taxRates.businessId, businessId));
    await tx
      .delete(loyaltyRules)
      .where(eq(loyaltyRules.businessId, businessId));
    await tx
      .delete(documentNumberSequences)
      .where(eq(documentNumberSequences.businessId, businessId));
  });
}
