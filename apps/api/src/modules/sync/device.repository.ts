import { and, asc, eq } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { devices } from '../../db/schema/identity/tables';
import type { SyncDeviceRecord } from './sync.types';

type DeviceRow = typeof devices.$inferSelect;

function toRecord(row: DeviceRow): SyncDeviceRecord {
  return {
    device_id: row.id,
    business_id: row.businessId,
    platform: row.platform,
    app_version: row.appVersion,
    device_name: row.deviceName,
    last_sync_at: row.lastSyncAt?.toISOString() ?? null,
    registered_at: row.createdAt.toISOString(),
  };
}

export class DeviceRepository {
  constructor(private readonly db: Database) {}

  async findByBusinessAndDeviceId(
    businessId: string,
    deviceId: string,
  ): Promise<SyncDeviceRecord | null> {
    const [row] = await this.db
      .select()
      .from(devices)
      .where(
        and(
          eq(devices.businessId, businessId),
          eq(devices.id, deviceId),
          eq(devices.isDeleted, false),
        ),
      )
      .limit(1);

    return row ? toRecord(row) : null;
  }

  async findAllByDeviceId(deviceId: string): Promise<DeviceRow[]> {
    return this.db
      .select()
      .from(devices)
      .where(and(eq(devices.id, deviceId), eq(devices.isDeleted, false)));
  }

  async upsert(input: {
    deviceId: string;
    businessId: string;
    userId?: string;
    platform: string;
    appVersion: string;
    deviceName: string;
  }): Promise<SyncDeviceRecord> {
    const now = new Date();
    const existing = await this.findByBusinessAndDeviceId(
      input.businessId,
      input.deviceId,
    );

    if (existing) {
      const [updated] = await this.db
        .update(devices)
        .set({
          platform: input.platform,
          appVersion: input.appVersion,
          deviceName: input.deviceName,
          userId: input.userId ?? null,
          lastSyncAt: now,
          updatedAt: now,
        })
        .where(
          and(
            eq(devices.businessId, input.businessId),
            eq(devices.id, input.deviceId),
            eq(devices.isDeleted, false),
          ),
        )
        .returning();

      if (!updated) {
        throw new Error('Failed to update device');
      }
      return toRecord(updated);
    }

    const [inserted] = await this.db
      .insert(devices)
      .values({
        id: input.deviceId,
        businessId: input.businessId,
        userId: input.userId ?? null,
        platform: input.platform,
        appVersion: input.appVersion,
        deviceName: input.deviceName,
        lastSyncAt: now,
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
        syncVersion: 1,
      })
      .returning();

    if (!inserted) {
      throw new Error('Failed to insert device');
    }
    return toRecord(inserted);
  }

  async listByBusiness(businessId: string): Promise<SyncDeviceRecord[]> {
    const rows = await this.db
      .select()
      .from(devices)
      .where(
        and(eq(devices.businessId, businessId), eq(devices.isDeleted, false)),
      )
      .orderBy(asc(devices.deviceName));

    return rows.map(toRecord);
  }
}
