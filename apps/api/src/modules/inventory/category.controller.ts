import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { sendData, sendPaginated } from '../../shared/http/response';
import {
  categoryIdParamSchema,
  createCategoryBodySchema,
  listCategoriesQuerySchema,
  updateCategoryBodySchema,
} from './category.schema';
import { CategoryService } from './category.service';
import type { PaginatedCategoriesResponse } from './category.types';
import {
  formatZodError,
  requireAuthContext,
} from './inventory.controller-helpers';

export function createCategoryController() {
  return {
    list: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<PaginatedCategoriesResponse> => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = listCategoriesQuerySchema.parse(request.query);
        const service = new CategoryService();
        const result = await service.listCategories(
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
        const body = createCategoryBodySchema.parse(request.body);
        const service = new CategoryService();
        const data = await service.createCategory(
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
        const { id } = categoryIdParamSchema.parse(request.params);
        const service = new CategoryService();
        const data = await service.getCategory(businessId, accountId, id);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid category ID',
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
        const { id } = categoryIdParamSchema.parse(request.params);
        const body = updateCategoryBodySchema.parse(request.body);
        const service = new CategoryService();
        const data = await service.updateCategory(
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
        const { id } = categoryIdParamSchema.parse(request.params);
        const service = new CategoryService();
        await service.deleteCategory(businessId, accountId, userId, id);
        return reply.status(204).send();
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid category ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },
  };
}
