import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import {
  companyMemberIdParamsSchema,
  updateCompanyMemberBodySchema,
} from './collaboration.schema';
import { CompanyMemberService } from './company-member.service';

function formatZodError(error: ZodError): Record<string, string[]> {
  const errors: Record<string, string[]> = {};
  for (const issue of error.issues) {
    const path = issue.path.join('.') || 'body';
    errors[path] = errors[path] ?? [];
    errors[path].push(issue.message);
  }
  return errors;
}

export function createCompanyMemberController() {
  return {
    list: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      const accountId = request.accountId;
      const businessId = request.businessId;
      if (!accountId || !businessId) {
        throw new AppError('UNAUTHORIZED', 'Business context required', 401);
      }

      const service = new CompanyMemberService();
      const data = await service.listMembers(businessId, accountId);
      return sendData(reply, data);
    },

    update: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      try {
        const accountId = request.accountId;
        const businessId = request.businessId;
        if (!accountId || !businessId) {
          throw new AppError('UNAUTHORIZED', 'Business context required', 401);
        }

        const { id } = companyMemberIdParamsSchema.parse(request.params);
        const body = updateCompanyMemberBodySchema.parse(request.body);
        const service = new CompanyMemberService();
        const data = await service.updateMember(
          id,
          businessId,
          accountId,
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

    remove: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      const accountId = request.accountId;
      const businessId = request.businessId;
      if (!accountId || !businessId) {
        throw new AppError('UNAUTHORIZED', 'Business context required', 401);
      }

      const { id } = companyMemberIdParamsSchema.parse(request.params);
      const service = new CompanyMemberService();
      await service.removeMember(id, businessId, accountId);
      return sendData(reply, { success: true });
    },

    leave: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      const accountId = request.accountId;
      if (!accountId) {
        throw new AppError('UNAUTHORIZED', 'Account not found in token', 401);
      }

      const { id } = companyMemberIdParamsSchema.parse(request.params);
      const service = new CompanyMemberService();
      await service.leaveCompany(id, accountId);
      return sendData(reply, { success: true });
    },
  };
}
