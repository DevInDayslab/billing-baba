import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { DeviceRepository } from './device.repository';
import type { RegisterDeviceBody } from './sync.schema';
import type { SyncDeviceRecord } from './sync.types';

export class DeviceService {
  constructor(private readonly repository?: DeviceRepository) {}

  private getRepository(): DeviceRepository {
    if (this.repository) {
      return this.repository;
    }
    const db = getDb();
    if (!db) {
      throw new AppError('SERVER_BUSY', 'Database is not configured', 429);
    }
    return new DeviceRepository(db);
  }

  /**
   * Register (or heartbeat) a device for the JWT business.
   *
   * The same physical device_id may register for many businesses and accounts.
   * Isolation is enforced by JWT membership + composite PK (business_id, id) —
   * registration never grants access to another business's data.
   */
  async register(
    accountId: string,
    businessId: string,
    userId: string | undefined,
    body: RegisterDeviceBody,
  ): Promise<SyncDeviceRecord> {
    void accountId;
    return this.getRepository().upsert({
      deviceId: body.device_id,
      businessId,
      userId,
      platform: body.platform,
      appVersion: body.app_version,
      deviceName: body.device_name,
    });
  }

  async list(businessId: string): Promise<{ devices: SyncDeviceRecord[] }> {
    const devices = await this.getRepository().listByBusiness(businessId);
    return { devices };
  }

  async isRegistered(businessId: string, deviceId: string): Promise<boolean> {
    const row = await this.getRepository().findByBusinessAndDeviceId(
      businessId,
      deviceId,
    );
    return row !== null;
  }

  async getDevice(
    businessId: string,
    deviceId: string,
  ): Promise<SyncDeviceRecord | null> {
    return this.getRepository().findByBusinessAndDeviceId(businessId, deviceId);
  }
}
