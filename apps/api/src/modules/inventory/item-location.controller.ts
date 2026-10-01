import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import type { AppConfig } from '../../config/app_config';
import { AppError } from '../../shared/errors/app-error';
import { sendData, sendPaginated } from '../../shared/http/response';
import { toUploadIntentResponse } from '../storage/storage.mapper';
import {
  formatZodError,
  requireAuthContext,
} from './inventory.controller-helpers';
import { ItemMediaService } from './item-media.service';
import { rackPhotoUploadBodySchema } from './item-media.schema';
import {
  createItemLocationBodySchema,
  itemLocationIdParamSchema,
  listItemLocationHistoryQuerySchema,
  listItemLocationsQuerySchema,
  updateItemLocationBodySchema,
} from './item-location.schema';
import { ItemLocationService } from './item-location.service';
import type { PaginatedItemLocationsResponse } from './item-location.types';

export function createItemLocationController(config: AppConfig) {
  const mediaService = new ItemMediaService({ config });

  return {
    list: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<PaginatedItemLocationsResponse> => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = listItemLocationsQuerySchema.parse(request.query);
        const service = new ItemLocationService();
        const result = await service.listItemLocations(
          businessId,
          accountId,
          query,
        );
        return sendPaginated(reply, result.data, result.meta);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid query parameters',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    create: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const body = createItemLocationBodySchema.parse(request.body);
        const service = new ItemLocationService();
        const data = await service.createItemLocation(
          businessId,
          accountId,
          userId,
          body,
        );
        return sendData(reply, data, 201);
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

    listHistory: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = itemLocationIdParamSchema.parse(request.params);
        const query = listItemLocationHistoryQuerySchema.parse(request.query);
        const service = new ItemLocationService();
        const result = await service.listItemLocationHistory(
          businessId,
          accountId,
          id,
          query,
        );
        return sendPaginated(reply, result.data, result.meta);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid query parameters',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    getById: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = itemLocationIdParamSchema.parse(request.params);
        const service = new ItemLocationService();
        const data = await service.getItemLocation(businessId, accountId, id);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid item location ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    update: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id } = itemLocationIdParamSchema.parse(request.params);
        const body = updateItemLocationBodySchema.parse(request.body);
        const service = new ItemLocationService();
        const data = await service.updateItemLocation(
          businessId,
          accountId,
          userId,
          id,
          body,
        );
        return sendData(reply, data);
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

    delete: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id } = itemLocationIdParamSchema.parse(request.params);
        const service = new ItemLocationService();
        await service.deleteItemLocation(businessId, accountId, userId, id);
        return reply.status(204).send();
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid item location ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    uploadPhoto: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id } = itemLocationIdParamSchema.parse(request.params);
        const body = rackPhotoUploadBodySchema.parse(request.body);

        if ('mime_type' in body) {
          const intent = await mediaService.createRackPhotoUploadIntent(
            businessId,
            accountId,
            id,
            body.mime_type,
            body.file_size,
            body.checksum,
          );
          return sendData(reply, toUploadIntentResponse(intent), 201);
        }

        const data = await mediaService.completeRackPhotoUpload(
          businessId,
          accountId,
          userId,
          id,
          body.intent_id,
          'employee_label' in body ? body.employee_label : undefined,
        );
        return sendData(reply, data);
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

    deletePhoto: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id } = itemLocationIdParamSchema.parse(request.params);
        await mediaService.deleteRackPhoto(businessId, accountId, userId, id);
        return reply.status(204).send();
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid item location ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },
  };
}
