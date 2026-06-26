import type { FastifyInstance } from 'fastify';

// TODO: Add middleware-level error hooks if needed beyond the global error handler.

export async function registerErrorMiddleware(
  _app: FastifyInstance,
): Promise<void> {
  // Placeholder — global error handling lives in app.ts for now.
}
