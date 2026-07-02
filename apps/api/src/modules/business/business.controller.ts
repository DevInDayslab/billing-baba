import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import type { ApiSuccessResponse } from '../../shared/types';
import { createBusinessBodySchema } from './business.schema';
import { BusinessService } from './business.service';
import type { BusinessDetail, BusinessListItem } from './business.types';

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
    ): Promise<ApiSuccessResponse<BusinessListItem[]>> => {
      const accountId = request.accountId;
      if (!accountId) {
        throw new AppError('UNAUTHORIZED', 'Account not found in token', 401);
      }

      const service = new BusinessService(request.server);
      const data = await service.listBusinesses(accountId);
      return reply.send({ success: true, data });
    },

    create: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<ApiSuccessResponse<BusinessDetail>> => {
      try {
        const accountId = request.accountId;
        const phone = request.phone;
        if (!accountId || !phone) {
          throw new AppError('UNAUTHORIZED', 'Account not found in token', 401);
        }

        const body = createBusinessBodySchema.parse(request.body);
        const service = new BusinessService(request.server);
        const data = await service.createBusiness(accountId, phone, body);
        return reply.status(201).send({ success: true, data });
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
