import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { sendData, sendPaginated } from '../../shared/http/response';
import {
  formatZodError,
  requireAuthContext,
} from './inventory.controller-helpers';
import {
  createUnitConversionBodySchema,
  listUnitConversionsQuerySchema,
  unitConversionIdParamSchema,
  updateUnitConversionBodySchema,
} from './unit.schema';
import type { PaginatedUnitConversionsResponse } from './unit.types';
import { UnitConversionService } from './unit-conversion.service';

export function createUnitConversionController() {
  return {
    list: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<PaginatedUnitConversionsResponse> => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = listUnitConversionsQuerySchema.parse(request.query);
        const service = new UnitConversionService();
        const result = await service.listUnitConversions(
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
        const body = createUnitConversionBodySchema.parse(request.body);
        const service = new UnitConversionService();
        const data = await service.createUnitConversion(
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
        const { id } = unitConversionIdParamSchema.parse(request.params);
        const service = new UnitConversionService();
        const data = await service.getUnitConversion(businessId, accountId, id);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid unit conversion ID',
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
        const { id } = unitConversionIdParamSchema.parse(request.params);
        const body = updateUnitConversionBodySchema.parse(request.body);
        const service = new UnitConversionService();
        const data = await service.updateUnitConversion(
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
        const { id } = unitConversionIdParamSchema.parse(request.params);
        const service = new UnitConversionService();
        await service.deleteUnitConversion(businessId, accountId, userId, id);
        return reply.status(204).send();
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid unit conversion ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },
  };
}
