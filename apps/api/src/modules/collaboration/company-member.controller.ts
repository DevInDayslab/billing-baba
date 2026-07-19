import type { FastifyReply, FastifyRequest } from 'fastify';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import { companyMemberIdParamsSchema } from './collaboration.schema';
import { CompanyMemberService } from './company-member.service';

export function createCompanyMemberController() {
  return {
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
