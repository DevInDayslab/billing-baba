import cors from '@fastify/cors';
import type { FastifyInstance } from 'fastify';

export async function registerCorsPlugin(app: FastifyInstance): Promise<void> {
  await app.register(cors, {
    origin: true,
  });
}
