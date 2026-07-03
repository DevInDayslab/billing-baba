import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { sendData, sendPaginated } from '../../shared/http/response';
import {
  brandIdParamSchema,
  createBrandBodySchema,
  listBrandsQuerySchema,
  updateBrandBodySchema,
} from './brand.schema';
import { BrandService } from './brand.service';
import type { PaginatedBrandsResponse } from './brand.types';
import {
  formatZodError,
  requireAuthContext,
} from './inventory.controller-helpers';

export function createBrandController() {
  return {
    list: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<PaginatedBrandsResponse> => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = listBrandsQuerySchema.parse(request.query);
        const service = new BrandService();
        const result = await service.listBrands(businessId, accountId, query);

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
        const body = createBrandBodySchema.parse(request.body);
        const service = new BrandService();
        const data = await service.createBrand(
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
        const { id } = brandIdParamSchema.parse(request.params);
        const service = new BrandService();
        const data = await service.getBrand(businessId, accountId, id);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid brand ID',
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
        const { id } = brandIdParamSchema.parse(request.params);
        const body = updateBrandBodySchema.parse(request.body);
        const service = new BrandService();
        const data = await service.updateBrand(
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
        const { id } = brandIdParamSchema.parse(request.params);
        const service = new BrandService();
        await service.deleteBrand(businessId, accountId, userId, id);
        return reply.status(204).send();
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid brand ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },
  };
}
