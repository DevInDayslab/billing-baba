import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import type { AppConfig } from '../../config/app_config';
import { AppError } from '../../shared/errors/app-error';
import { sendData, sendPaginated } from '../../shared/http/response';
import {
  formatZodError,
  requireAuthContext,
} from './inventory.controller-helpers';
import { ItemMediaService } from './item-media.service';
import {
  itemImageUploadBodySchema,
  reorderItemImagesBodySchema,
} from './item-media.schema';
import { toUploadIntentResponse } from '../storage/storage.mapper';
import {
  createItemBodySchema,
  createItemImageBodySchema,
  itemIdParamSchema,
  itemImageParamSchema,
  itemTierParamSchema,
  listItemPriceHistoryQuerySchema,
  listItemsQuerySchema,
  putItemAlternativesBodySchema,
  putItemTierPricesBodySchema,
  updateItemBodySchema,
  updateItemImageBodySchema,
} from './item.schema';
import { ItemService } from './item.service';
import type { PaginatedItemsResponse } from './item.types';

export function createItemController(config: AppConfig) {
  const mediaService = new ItemMediaService({ config });

  return {
    list: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<PaginatedItemsResponse> => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = listItemsQuerySchema.parse(request.query);
        const service = new ItemService(config);
        const result = await service.listItems(businessId, accountId, query);
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
        const body = createItemBodySchema.parse(request.body);
        const service = new ItemService(config);
        const data = await service.createItem(
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

    getById: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = itemIdParamSchema.parse(request.params);
        const service = new ItemService(config);
        const data = await service.getItem(businessId, accountId, id);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid item ID',
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
        const { id } = itemIdParamSchema.parse(request.params);
        const body = updateItemBodySchema.parse(request.body);
        const service = new ItemService(config);
        const data = await service.updateItem(
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
        const { id } = itemIdParamSchema.parse(request.params);
        const service = new ItemService(config);
        await service.deleteItem(businessId, accountId, userId, id);
        return reply.status(204).send();
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid item ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    listImages: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = itemIdParamSchema.parse(request.params);
        const service = new ItemService(config);
        const images = await service.listItemImages(businessId, accountId, id);
        const enriched = await mediaService.enrichItemImages(
          businessId,
          accountId,
          images,
        );
        return sendData(reply, enriched);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid item ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    addImage: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id } = itemIdParamSchema.parse(request.params);
        const body = itemImageUploadBodySchema.parse(request.body);

        if ('mime_type' in body) {
          const intent = await mediaService.createItemImageUploadIntent(
            businessId,
            accountId,
            id,
            body.mime_type,
            body.file_size,
            body.checksum,
          );
          return sendData(reply, toUploadIntentResponse(intent), 201);
        }

        if ('intent_id' in body) {
          const data = await mediaService.completeItemImageUpload(
            businessId,
            accountId,
            userId,
            id,
            body.intent_id,
            {
              isPrimary: body.is_primary,
              sortOrder: body.sort_order,
              replacesImageId: body.replaces_image_id,
            },
          );
          return sendData(reply, data);
        }

        const service = new ItemService(config);
        const data = await service.addItemImage(
          businessId,
          accountId,
          userId,
          id,
          {
            image_url: body.image_url,
            sort_order: body.sort_order,
            is_primary: body.is_primary,
          },
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

    getTierPrices: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = itemIdParamSchema.parse(request.params);
        const service = new ItemService(config);
        const data = await service.getItemTierPrices(businessId, accountId, id);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid item ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    putTierPrices: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id } = itemIdParamSchema.parse(request.params);
        const body = putItemTierPricesBodySchema.parse(request.body);
        const service = new ItemService(config);
        const data = await service.putItemTierPrices(
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

    getPriceHistory: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = itemIdParamSchema.parse(request.params);
        const query = listItemPriceHistoryQuerySchema.parse(request.query);
        const service = new ItemService(config);
        const result = await service.listItemPriceHistory(
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

    updateImage: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id, imageId } = itemImageParamSchema.parse(request.params);
        const body = updateItemImageBodySchema.parse(request.body);

        if (body.is_primary === true && Object.keys(body).length === 1) {
          const data = await mediaService.setPrimaryItemImage(
            businessId,
            accountId,
            userId,
            id,
            imageId,
          );
          return sendData(reply, data);
        }

        const service = new ItemService(config);
        const data = await service.updateItemImage(
          businessId,
          accountId,
          userId,
          id,
          imageId,
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

    reorderImages: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = itemIdParamSchema.parse(request.params);
        const body = reorderItemImagesBodySchema.parse(request.body);
        const images = await mediaService.reorderItemImages(
          businessId,
          accountId,
          id,
          body.image_ids,
        );
        const enriched = await mediaService.enrichItemImages(
          businessId,
          accountId,
          images,
        );
        return sendData(reply, enriched);
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

    deleteImage: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id, imageId } = itemImageParamSchema.parse(request.params);
        await mediaService.deleteItemImageMedia(
          businessId,
          accountId,
          userId,
          id,
          imageId,
        );
        return reply.status(204).send();
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid image ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    deleteTierPrice: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id, tier } = itemTierParamSchema.parse(request.params);
        const service = new ItemService(config);
        await service.deleteItemTierPrice(
          businessId,
          accountId,
          userId,
          id,
          tier,
        );
        return reply.status(204).send();
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid tier parameter',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    getAlternativesIndex: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ) => {
      const { accountId, businessId } = requireAuthContext(request);
      const service = new ItemService(config);
      const data = await service.getAlternativesIndex(businessId, accountId);
      return sendData(reply, data);
    },

    listAlternatives: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = itemIdParamSchema.parse(request.params);
        const service = new ItemService(config);
        const data = await service.listItemAlternatives(
          businessId,
          accountId,
          id,
        );
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid item ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    putAlternatives: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id } = itemIdParamSchema.parse(request.params);
        const body = putItemAlternativesBodySchema.parse(request.body);
        const service = new ItemService(config);
        const data = await service.putItemAlternatives(
          businessId,
          accountId,
          userId,
          id,
          body.alternative_item_ids,
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
  };
}
