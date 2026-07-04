import type { FastifyReply } from 'fastify';
import {
  buildPaginationMeta,
  type PaginationInput,
  type PaginationMeta,
} from './pagination';

export type PaginatedPayload<T> = {
  data: T[];
  meta: PaginationMeta;
};

export function sendData<T>(
  reply: FastifyReply,
  data: T,
  statusCode = 200,
): FastifyReply {
  return reply.status(statusCode).send({ data });
}

export function sendPaginated<T>(
  reply: FastifyReply,
  data: T[],
  meta: PaginationInput,
  statusCode = 200,
): FastifyReply {
  return reply.status(statusCode).send({
    data,
    meta: buildPaginationMeta(meta),
  });
}

export function toPaginatedResult<T>(
  data: T[],
  meta: PaginationInput,
): PaginatedPayload<T> {
  return {
    data,
    meta: buildPaginationMeta(meta),
  };
}
