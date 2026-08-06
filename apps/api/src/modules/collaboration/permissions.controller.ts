import type { FastifyReply, FastifyRequest } from 'fastify';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import { BusinessAccessService } from '../../shared/permissions/business-access.service';

export function createPermissionsController() {
  return {
    current: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<FastifyReply> => {
      const accountId = request.accountId;
      const businessId = request.businessId;
      if (!accountId || !businessId) {
        throw new AppError('UNAUTHORIZED', 'Business context required', 401);
      }

      const db = getDb();
      if (!db) {
        throw new AppError(
          'DATABASE_NOT_CONFIGURED',
          'Database is not configured',
          503,
        );
      }

      const access = await new BusinessAccessService(db).resolve(
        accountId,
        businessId,
        request.role,
      );

      return sendData(reply, {
        access_kind: access.kind,
        collaboration_role: access.kind === 'collaborator' ? access.role : null,
        preset:
          access.kind === 'collaborator'
            ? new BusinessAccessService(db).currentPreset(access)
            : null,
      });
    },
  };
}
