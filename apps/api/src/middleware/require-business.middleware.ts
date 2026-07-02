import type { FastifyReply, FastifyRequest } from 'fastify';
import { AppError } from '../shared/errors/app-error';

export async function requireBusiness(
  request: FastifyRequest,
  _reply: FastifyReply,
): Promise<void> {
  if (!request.businessId) {
    throw new AppError(
      'BUSINESS_NOT_SELECTED',
      'Select a business before accessing this resource',
      400,
    );
  }
}
