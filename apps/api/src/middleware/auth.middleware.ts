import type { FastifyInstance } from 'fastify';

export async function registerAuthMiddleware(
  _app: FastifyInstance,
): Promise<void> {
  // TODO: Verify JWT and attach userId / businessId to the request context.
}
