import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import type { AppConfig } from '../../config/app_config';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import {
  formatZodError,
  requireAuthContext,
} from '../inventory/inventory.controller-helpers';
import {
  toStorageAssetResponse,
  toUploadIntentResponse,
} from './storage.mapper';
import {
  completeUploadBodySchema,
  createUploadIntentBodySchema,
  storageFileIdParamSchema,
} from './storage.schema';
import { StorageService } from './storage.service';

export function createStorageController(
  config: AppConfig,
  service?: StorageService,
) {
  const storageService =
    service ??
    new StorageService({
      config,
    });

  return {
    createUploadIntent: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const body = createUploadIntentBodySchema.parse(request.body);
        const intent = await storageService.createUploadIntent(
          businessId,
          accountId,
          {
            purpose: body.purpose,
            visibility: body.visibility,
            mimeType: body.mime_type,
            fileSize: body.file_size,
            ownerType: body.owner_type,
            ownerId: body.owner_id,
            checksum: body.checksum,
          },
        );
        return sendData(reply, toUploadIntentResponse(intent), 201);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid request body',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    completeUpload: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const body = completeUploadBodySchema.parse(request.body);
        const asset = await storageService.completeUpload(
          businessId,
          accountId,
          body.intent_id,
        );
        return sendData(reply, toStorageAssetResponse(asset));
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid request body',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    getFile: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = storageFileIdParamSchema.parse(request.params);
        const asset = await storageService.getAsset(businessId, accountId, id);
        return sendData(reply, toStorageAssetResponse(asset));
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid file ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    getFileUrl: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = storageFileIdParamSchema.parse(request.params);
        const result = await storageService.getDownloadUrl(
          businessId,
          accountId,
          id,
        );
        return sendData(reply, {
          url: result.url,
          expires_at: result.expiresAt,
          visibility: result.visibility,
        });
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid file ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    deleteFile: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = storageFileIdParamSchema.parse(request.params);
        await storageService.deleteAsset(businessId, accountId, id);
        return sendData(reply, { deleted: true });
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid file ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },
  };
}
