import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { sendData, sendPaginated } from '../../shared/http/response';
import {
  formatZodError,
  requireAuthContext,
} from './inventory.controller-helpers';
import {
  createItemBodySchema,
  createItemImageBodySchema,
  itemIdParamSchema,
  itemImageParamSchema,
  itemTierParamSchema,
  listItemPriceHistoryQuerySchema,
  listItemsQuerySchema,
  putItemTierPricesBodySchema,
  updateItemBodySchema,
  updateItemImageBodySchema,
} from './item.schema';
import { ItemService } from './item.service';
import type { PaginatedItemsResponse } from './item.types';

export function createItemController() {
  return {
    list: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<PaginatedItemsResponse> => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = listItemsQuerySchema.parse(request.query);
        const service = new ItemService();
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
        const service = new ItemService();
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
        const service = new ItemService();
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
        const service = new ItemService();
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
        const service = new ItemService();
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
        const service = new ItemService();
        const data = await service.listItemImages(businessId, accountId, id);
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

    addImage: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id } = itemIdParamSchema.parse(request.params);
        const body = createItemImageBodySchema.parse(request.body);
        const service = new ItemService();
        const data = await service.addItemImage(
          businessId,
          accountId,
          userId,
          id,
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

    getTierPrices: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = itemIdParamSchema.parse(request.params);
        const service = new ItemService();
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
        const service = new ItemService();
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
        const service = new ItemService();
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
        const service = new ItemService();
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

    deleteImage: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId, userId } = requireAuthContext(request);
        const { id, imageId } = itemImageParamSchema.parse(request.params);
        const service = new ItemService();
        await service.deleteItemImage(
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
        const service = new ItemService();
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
  };
}
