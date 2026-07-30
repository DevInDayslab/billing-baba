import type { FastifyRequest } from 'fastify';
import type { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import type { DeviceService } from './device.service';
import {
  SYNC_HEADER_APP_VERSION,
  SYNC_HEADER_DEVICE_ID,
  SYNC_HEADER_PROTOCOL_VERSION,
  SYNC_PROTOCOL_VERSION,
} from './sync.constants';
import {
  syncDeviceNotRegistered,
  syncProtocolMismatch,
  syncValidationFailed,
} from './sync.errors';
import { type SyncHeaders, syncHeadersSchema } from './sync.schema';

export function formatSyncZodError(error: ZodError): Record<string, string[]> {
  const errors: Record<string, string[]> = {};
  for (const issue of error.issues) {
    const path = issue.path.join('.') || 'body';
    errors[path] = errors[path] ?? [];
    errors[path].push(issue.message);
  }
  return errors;
}

export function requireSyncAuthContext(request: FastifyRequest): {
  accountId: string;
  businessId: string;
  userId?: string;
} {
  const accountId = request.accountId;
  const businessId = request.businessId;
  if (!accountId) {
    throw new AppError('UNAUTHORIZED', 'Account not found in token', 401);
  }
  if (!businessId) {
    throw new AppError(
      'BUSINESS_REQUIRED',
      'JWT must include business_id for sync',
      403,
    );
  }
  return {
    accountId,
    businessId,
    userId: request.userId,
  };
}

function headerValue(
  headers: FastifyRequest['headers'],
  name: string,
): string | undefined {
  const raw = headers[name];
  if (Array.isArray(raw)) {
    return raw[0];
  }
  return raw;
}

export function parseSyncHeaders(request: FastifyRequest): SyncHeaders {
  const candidate = {
    [SYNC_HEADER_DEVICE_ID]: headerValue(
      request.headers,
      SYNC_HEADER_DEVICE_ID,
    ),
    [SYNC_HEADER_APP_VERSION]: headerValue(
      request.headers,
      SYNC_HEADER_APP_VERSION,
    ),
    [SYNC_HEADER_PROTOCOL_VERSION]: headerValue(
      request.headers,
      SYNC_HEADER_PROTOCOL_VERSION,
    ),
  };

  const parsed = syncHeadersSchema.safeParse(candidate);
  if (!parsed.success) {
    const protocol = candidate[SYNC_HEADER_PROTOCOL_VERSION];
    if (
      protocol !== undefined &&
      protocol !== '' &&
      Number(protocol) !== SYNC_PROTOCOL_VERSION
    ) {
      throw syncProtocolMismatch(
        `Unsupported X-Sync-Protocol-Version: ${protocol}`,
      );
    }
    throw syncValidationFailed(
      'Invalid sync headers',
      formatSyncZodError(parsed.error),
    );
  }
  return parsed.data;
}

export async function requireRegisteredDevice(
  deviceService: DeviceService,
  businessId: string,
  deviceId: string,
): Promise<void> {
  const exists = await deviceService.isRegistered(businessId, deviceId);
  if (!exists) {
    throw syncDeviceNotRegistered();
  }
}

export function assertDeviceIdMatch(
  headerDeviceId: string,
  bodyDeviceId: string,
): void {
  if (headerDeviceId !== bodyDeviceId) {
    throw syncValidationFailed('X-Device-Id must match body device_id', {
      device_id: ['Must equal X-Device-Id header'],
    });
  }
}
