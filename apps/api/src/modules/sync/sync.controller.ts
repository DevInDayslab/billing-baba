import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { getDb } from '../../db/client';
import { sendData } from '../../shared/http/response';
import { BusinessAccessService } from '../../shared/permissions/business-access.service';
import { BootstrapService } from './bootstrap.service';
import { DeviceService } from './device.service';
import { MediaService } from './media.service';
import { PullService } from './pull.service';
import { PushService } from './push.service';
import { StatusService } from './status.service';
import {
  assertDeviceIdMatch,
  formatSyncZodError,
  parseSyncHeaders,
  requireRegisteredDevice,
  requireSyncAuthContext,
} from './sync.auth';
import { SYNC_HEADER_DEVICE_ID } from './sync.constants';
import { syncValidationFailed } from './sync.errors';
import {
  bootstrapBodySchema,
  mediaAssetParamsSchema,
  mediaUploadCompleteBodySchema,
  mediaUploadIntentBodySchema,
  mediaUrlQuerySchema,
  pullQuerySchema,
  pushBodySchema,
  registerDeviceBodySchema,
} from './sync.schema';

export function createSyncController() {
  const deviceService = new DeviceService();
  const statusService = new StatusService(deviceService);
  const bootstrapService = new BootstrapService();
  const pushService = new PushService();
  const pullService = new PullService();

  async function resolveAccess(request: FastifyRequest) {
    const accountId = request.accountId;
    const businessId = request.businessId;
    if (!accountId || !businessId) {
      return undefined;
    }
    const db = getDb();
    if (!db) {
      return undefined;
    }
    return new BusinessAccessService(db).resolve(
      accountId,
      businessId,
      request.role,
    );
  }

  const mediaService = new MediaService();

  return {
    registerDevice: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } =
          requireSyncAuthContext(request);
        const headers = parseSyncHeaders(request);
        const body = registerDeviceBodySchema.parse(request.body);
        assertDeviceIdMatch(headers[SYNC_HEADER_DEVICE_ID], body.device_id);
        const data = await deviceService.register(
          accountId,
          businessId,
          userId,
          body,
        );
        return sendData(reply, data);
      } catch (error) {
        throw mapZod(error);
      }
    },

    listDevices: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { businessId } = requireSyncAuthContext(request);
        parseSyncHeaders(request);
        const data = await deviceService.list(businessId);
        return sendData(reply, data);
      } catch (error) {
        throw mapZod(error);
      }
    },

    getStatus: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { businessId } = requireSyncAuthContext(request);
        const headers = parseSyncHeaders(request);
        const deviceId = headers[SYNC_HEADER_DEVICE_ID];
        await requireRegisteredDevice(deviceService, businessId, deviceId);
        const data = await statusService.getStatus(businessId, deviceId);
        return sendData(reply, data);
      } catch (error) {
        throw mapZod(error);
      }
    },

    startBootstrap: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { businessId } = requireSyncAuthContext(request);
        const headers = parseSyncHeaders(request);
        const body = bootstrapBodySchema.parse(request.body);
        assertDeviceIdMatch(headers[SYNC_HEADER_DEVICE_ID], body.device_id);
        await requireRegisteredDevice(
          deviceService,
          businessId,
          body.device_id,
        );
        const data = bootstrapService.start(businessId, body);
        return sendData(reply, data, 202);
      } catch (error) {
        throw mapZod(error);
      }
    },

    push: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { businessId, userId } = requireSyncAuthContext(request);
        const headers = parseSyncHeaders(request);
        const body = pushBodySchema.parse(request.body);
        assertDeviceIdMatch(headers[SYNC_HEADER_DEVICE_ID], body.device_id);
        await requireRegisteredDevice(
          deviceService,
          businessId,
          body.device_id,
        );
        const data = await pushService.process(
          businessId,
          body,
          userId,
          await resolveAccess(request),
        );
        return sendData(reply, data);
      } catch (error) {
        throw mapZod(error);
      }
    },

    pull: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { businessId } = requireSyncAuthContext(request);
        const headers = parseSyncHeaders(request);
        await requireRegisteredDevice(
          deviceService,
          businessId,
          headers[SYNC_HEADER_DEVICE_ID],
        );
        const query = pullQuerySchema.parse(request.query);
        const data = await pullService.pull(
          businessId,
          query,
          await resolveAccess(request),
        );
        return sendData(reply, data);
      } catch (error) {
        throw mapZod(error);
      }
    },

    mediaUploadIntent: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { businessId } = requireSyncAuthContext(request);
        const headers = parseSyncHeaders(request);
        const body = mediaUploadIntentBodySchema.parse(request.body);
        assertDeviceIdMatch(headers[SYNC_HEADER_DEVICE_ID], body.device_id);
        await requireRegisteredDevice(
          deviceService,
          businessId,
          body.device_id,
        );
        const data = mediaService.createUploadIntent(body);
        return sendData(reply, data);
      } catch (error) {
        throw mapZod(error);
      }
    },

    mediaUploadComplete: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ) => {
      try {
        const { businessId } = requireSyncAuthContext(request);
        const headers = parseSyncHeaders(request);
        await requireRegisteredDevice(
          deviceService,
          businessId,
          headers[SYNC_HEADER_DEVICE_ID],
        );
        const body = mediaUploadCompleteBodySchema.parse(request.body);
        const data = mediaService.completeUpload(body);
        return sendData(reply, data);
      } catch (error) {
        throw mapZod(error);
      }
    },

    mediaDownloadUrl: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { businessId } = requireSyncAuthContext(request);
        const headers = parseSyncHeaders(request);
        await requireRegisteredDevice(
          deviceService,
          businessId,
          headers[SYNC_HEADER_DEVICE_ID],
        );
        const params = mediaAssetParamsSchema.parse(request.params);
        const query = mediaUrlQuerySchema.parse(request.query);
        const data = mediaService.getDownloadUrl(
          params.asset_id,
          query.variant,
        );
        return sendData(reply, data);
      } catch (error) {
        throw mapZod(error);
      }
    },
  };
}

function mapZod(error: unknown): unknown {
  if (error instanceof ZodError) {
    return syncValidationFailed(
      'Invalid sync request',
      formatSyncZodError(error),
    );
  }
  return error;
}
