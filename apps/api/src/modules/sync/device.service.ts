import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { DeviceRepository } from './device.repository';
import { syncBusinessChanged } from './sync.errors';
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

  async register(
    businessId: string,
    userId: string | undefined,
    body: RegisterDeviceBody,
  ): Promise<SyncDeviceRecord> {
    const repo = this.getRepository();
    const other = await repo.findByIdAnyBusiness(body.device_id);
    if (other && other.businessId !== businessId) {
      throw syncBusinessChanged(
        'This device_id is already registered to another business',
      );
    }

    return repo.upsert({
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
