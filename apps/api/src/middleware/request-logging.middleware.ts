import type { FastifyInstance } from 'fastify';

declare module 'fastify' {
  interface FastifyRequest {
    startTime?: number;
  }
}

export async function registerRequestLoggingMiddleware(
  app: FastifyInstance,
): Promise<void> {
  app.addHook('onRequest', async (request, reply) => {
    request.startTime = Date.now();
    reply.header('X-Request-Id', request.id);

    request.log.info(
      {
        method: request.method,
        path: request.url,
        remoteAddress: request.ip,
      },
      'incoming request',
    );
  });

  app.addHook('onResponse', async (request, reply) => {
    const duration = request.startTime
      ? Date.now() - request.startTime
      : undefined;

    request.log.info(
      {
        method: request.method,
        path: request.url,
        statusCode: reply.statusCode,
        ...(duration !== undefined ? { duration } : {}),
      },
      'request completed',
    );
  });
}
