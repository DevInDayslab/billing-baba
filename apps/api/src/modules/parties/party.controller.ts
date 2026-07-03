import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import {
  createPartyBodySchema,
  listPartiesQuerySchema,
  partyIdParamSchema,
  updatePartyBodySchema,
} from './party.schema';
import { PartyService } from './party.service';
import type { PaginatedPartiesResponse } from './party.types';

function formatZodError(error: ZodError): Record<string, string[]> {
  const errors: Record<string, string[]> = {};
  for (const issue of error.issues) {
    const path = issue.path.join('.') || 'body';
    errors[path] = errors[path] ?? [];
    errors[path].push(issue.message);
  }
  return errors;
}

function requireAuthContext(request: FastifyRequest): {
  accountId: string;
  businessId: string;
  userId?: string;
} {
  const accountId = request.accountId;
  const businessId = request.businessId;
  if (!accountId || !businessId) {
    throw new AppError(
      'UNAUTHORIZED',
      'Account or business not found in token',
      401,
    );
  }

  return {
    accountId,
    businessId,
    userId: request.userId,
  };
}

export function createPartyController() {
  return {
    list: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<PaginatedPartiesResponse> => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = listPartiesQuerySchema.parse(request.query);
        const service = new PartyService();
        const result = await service.listParties(businessId, accountId, query);

        return reply.send({
          success: true,
          data: result.data,
          meta: result.meta,
        });
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
        const body = createPartyBodySchema.parse(request.body);
        const service = new PartyService();
        const data = await service.createParty(
          businessId,
          accountId,
          userId,
          body,
        );
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

    getById: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = partyIdParamSchema.parse(request.params);
        const service = new PartyService();
        const data = await service.getParty(businessId, accountId, id);
        return reply.send({ success: true, data });
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid party ID',
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
        const { id } = partyIdParamSchema.parse(request.params);
        const body = updatePartyBodySchema.parse(request.body);
        const service = new PartyService();
        const data = await service.updateParty(
          businessId,
          accountId,
          userId,
          id,
          body,
        );
        return reply.send({ success: true, data });
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
        const { id } = partyIdParamSchema.parse(request.params);
        const service = new PartyService();
        await service.deleteParty(businessId, accountId, userId, id);
        return reply.status(204).send();
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid party ID',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },
  };
}
