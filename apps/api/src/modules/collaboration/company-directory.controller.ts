import type { FastifyReply, FastifyRequest } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import { CompanyDirectoryService } from './company-directory.service';

export function createCompanyDirectoryController(config: AppConfig) {
  return {
    listShared: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      const accountId = request.accountId;
      if (!accountId) {
        throw new AppError('UNAUTHORIZED', 'Account not found in token', 401);
      }

      const service = new CompanyDirectoryService(config);
      const data = await service.listSharedCompanies(accountId);
      return sendData(reply, data);
    },

    listInvitations: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      const accountId = request.accountId;
      const phone = request.phone;
      if (!accountId || !phone) {
        throw new AppError('UNAUTHORIZED', 'Account not found in token', 401);
      }

      const service = new CompanyDirectoryService(config);
      const data = await service.listPendingInvitations(accountId, phone);
      return sendData(reply, data);
    },
  };
}
