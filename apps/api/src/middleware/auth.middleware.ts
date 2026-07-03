import type { FastifyInstance, FastifyReply, FastifyRequest } from 'fastify';
import type { JwtAccessPayload } from '../modules/auth/auth.types';
import { AppError } from '../shared/errors/app-error';

export async function authenticate(
  request: FastifyRequest,
  _reply: FastifyReply,
): Promise<void> {
  try {
    await request.jwtVerify<JwtAccessPayload>();
  } catch {
    throw new AppError('UNAUTHORIZED', 'Invalid or expired access token', 401);
  }

  const payload = request.user as JwtAccessPayload;
  request.accountId = payload.account_id;
  request.phone = payload.phone;
  request.userId = payload.user_id;
  request.businessId = payload.business_id;
  request.role = payload.role;
}

export async function registerAuthMiddleware(
  _app: FastifyInstance,
): Promise<void> {
  // Route-level authentication uses the `authenticate` preHandler.
}
