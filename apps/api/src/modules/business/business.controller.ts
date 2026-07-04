import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { sendData, sendPaginated } from '../../shared/http/response';
import {
  createBusinessBodySchema,
  updateBusinessProfileBodySchema,
} from './business.schema';
import { BusinessService } from './business.service';

function formatZodError(error: ZodError): Record<string, string[]> {
  const errors: Record<string, string[]> = {};
  for (const issue of error.issues) {
    const path = issue.path.join('.') || 'body';
    errors[path] = errors[path] ?? [];
    errors[path].push(issue.message);
  }
  return errors;
}

export function createBusinessController() {
  return {
    list: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      const accountId = request.accountId;
      if (!accountId) {
        throw new AppError('UNAUTHORIZED', 'Account not found in token', 401);
      }

      const service = new BusinessService();
      const data = await service.listBusinesses(accountId);
      return sendData(reply, data);
    },

    create: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      try {
        const accountId = request.accountId;
        const phone = request.phone;
        if (!accountId || !phone) {
          throw new AppError('UNAUTHORIZED', 'Account not found in token', 401);
        }

        const body = createBusinessBodySchema.parse(request.body);
        const service = new BusinessService();
        const data = await service.createBusiness(accountId, phone, body);
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

    getProfile: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      const accountId = request.accountId;
      const businessId = request.businessId;
      if (!accountId || !businessId) {
        throw new AppError('UNAUTHORIZED', 'Account not found in token', 401);
      }

      const service = new BusinessService();
      const data = await service.getProfile(businessId, accountId);
      return sendData(reply, data);
    },

    updateProfile: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      try {
        const accountId = request.accountId;
        const businessId = request.businessId;
        if (!accountId || !businessId) {
          throw new AppError('UNAUTHORIZED', 'Account not found in token', 401);
        }

        const body = updateBusinessProfileBodySchema.parse(request.body);
        const service = new BusinessService();
        const data = await service.updateProfile(businessId, accountId, body);
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
