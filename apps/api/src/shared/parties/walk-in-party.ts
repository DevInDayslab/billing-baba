import { createHash } from 'node:crypto';
import { eq } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { parties } from '../../db/schema/crm/tables';

type DbLike = Pick<Database, 'select' | 'insert'>;

/** Legacy client constant — one row per business when used. */
export const LEGACY_WALK_IN_PARTY_ID = 'a0000000-0000-4000-8000-000000000001';

export const WALK_IN_PARTY_NAME = 'Walk-in Customer';

const WALK_IN_NAMESPACE = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';

function uuidToBytes(uuid: string): Buffer {
  return Buffer.from(uuid.replace(/-/g, ''), 'hex');
}

function bytesToUuid(bytes: Buffer): string {
  const hex = bytes.toString('hex');
  return `${hex.slice(0, 8)}-${hex.slice(8, 12)}-${hex.slice(12, 16)}-${hex.slice(16, 20)}-${hex.slice(20)}`;
}

/** Deterministic walk-in party id scoped to a business. */
export function walkInPartyIdForBusiness(businessId: string): string {
  const namespace = uuidToBytes(WALK_IN_NAMESPACE);
  const hash = createHash('sha1')
    .update(namespace)
    .update(`billing-baba:walk-in-party:${businessId}`)
    .digest();
  const bytes = Buffer.from(hash.subarray(0, 16));
  bytes[6] = (bytes[6]! & 0x0f) | 0x50;
  bytes[8] = (bytes[8]! & 0x3f) | 0x80;
  return bytesToUuid(bytes);
}

export function isWalkInPartyId(
  businessId: string,
  partyId: string | null | undefined,
): boolean {
  if (!partyId) return false;
  return (
    partyId === LEGACY_WALK_IN_PARTY_ID ||
    partyId === walkInPartyIdForBusiness(businessId)
  );
}

/** Creates the walk-in party row when a synced sale references it. */
export async function ensureWalkInParty(
  db: DbLike,
  businessId: string,
  partyId: string,
): Promise<void> {
  if (!isWalkInPartyId(businessId, partyId)) {
    return;
  }

  const [existing] = await db
    .select({ businessId: parties.businessId })
    .from(parties)
    .where(eq(parties.id, partyId))
    .limit(1);

  if (existing) {
    if (existing.businessId !== businessId) {
      throw new Error(`Walk-in party ${partyId} belongs to another business`);
    }
    return;
  }

  const now = new Date();
  await db.insert(parties).values({
    id: partyId,
    businessId,
    name: WALK_IN_PARTY_NAME,
    partyType: 'customer',
    isActive: true,
    syncVersion: 1,
    createdAt: now,
    updatedAt: now,
    isDeleted: false,
    deletedAt: null,
  });
}

/** Seeds the canonical walk-in party when a business is provisioned. */
export async function seedWalkInPartyForBusiness(
  db: DbLike,
  businessId: string,
): Promise<void> {
  await ensureWalkInParty(db, businessId, walkInPartyIdForBusiness(businessId));
}
