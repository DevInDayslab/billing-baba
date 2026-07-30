import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import type { AppConfig } from '../../config/app_config';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import {
  createInvitationBodySchema,
  invitationIdParamsSchema,
  invitationTokenParamsSchema,
} from './collaboration.schema';
import { InvitationService } from './invitation.service';

function formatZodError(error: ZodError): Record<string, string[]> {
  const errors: Record<string, string[]> = {};
  for (const issue of error.issues) {
    const path = issue.path.join('.') || 'body';
    errors[path] = errors[path] ?? [];
    errors[path].push(issue.message);
  }
  return errors;
}

export function createInvitationController(config: AppConfig) {
  const service = new InvitationService(config);

  return {
    create: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      try {
        const accountId = request.accountId;
        const businessId = request.businessId;
        if (!accountId || !businessId) {
          throw new AppError('UNAUTHORIZED', 'Business context required', 401);
        }

        const body = createInvitationBodySchema.parse(request.body);
        const data = await service.createInvitation(
          businessId,
          accountId,
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

    getByToken: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      const { token } = invitationTokenParamsSchema.parse(request.params);
      const data = await service.getInvitationByToken(token);
      return sendData(reply, data);
    },

    accept: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      const { token } = invitationTokenParamsSchema.parse(request.params);
      const data = await service.acceptInvitation(token);
      return sendData(reply, data);
    },

    reject: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      const { token } = invitationTokenParamsSchema.parse(request.params);
      const data = await service.rejectInvitation(token);
      return sendData(reply, data);
    },

    reinvite: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      const accountId = request.accountId;
      const businessId = request.businessId;
      if (!accountId || !businessId) {
        throw new AppError('UNAUTHORIZED', 'Business context required', 401);
      }

      const { id } = invitationIdParamsSchema.parse(request.params);
      const data = await service.reinvite(id, businessId, accountId);
      return sendData(reply, data, 201);
    },

    list: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      const accountId = request.accountId;
      const businessId = request.businessId;
      if (!accountId || !businessId) {
        throw new AppError('UNAUTHORIZED', 'Business context required', 401);
      }

      const data = await service.listInvitations(businessId, accountId);
      return sendData(reply, data);
    },

    cancel: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      const accountId = request.accountId;
      const businessId = request.businessId;
      if (!accountId || !businessId) {
        throw new AppError('UNAUTHORIZED', 'Business context required', 401);
      }

      const { id } = invitationIdParamsSchema.parse(request.params);
      const data = await service.cancelInvitation(id, businessId, accountId);
      return sendData(reply, data);
    },
  };
}
