import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { sendData, sendPaginated } from '../../shared/http/response';
import {
  createTodoBodySchema,
  listTodosQuerySchema,
  todoIdParamSchema,
  updateTodoBodySchema,
} from './todo.schema';
import { TodoService } from './todo.service';

function formatZodError(error: ZodError): Record<string, string[]> {
  const errors: Record<string, string[]> = {};
  for (const issue of error.issues) {
    const path = issue.path.join('.') || 'body';
    errors[path] = errors[path] ?? [];
    errors[path].push(issue.message);
  }
  return errors;
}

function requireBusinessId(request: FastifyRequest): string {
  const businessId = request.businessId;
  if (!businessId) {
    throw new AppError('UNAUTHORIZED', 'Business context required', 401);
  }
  return businessId;
}

export function createTodoController() {
  const service = new TodoService();

  return {
    list: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const businessId = requireBusinessId(request);
        const query = listTodosQuerySchema.parse(request.query);
        const result = await service.list(businessId, query);
        return sendPaginated(reply, result.data, result.meta);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid query parameters',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    create: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const businessId = requireBusinessId(request);
        const body = createTodoBodySchema.parse(request.body);
        const data = await service.create(businessId, body);
        return sendData(reply, data, 201);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid request body',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    getById: async (request: FastifyRequest, reply: FastifyReply) => {
      const businessId = requireBusinessId(request);
      const { id } = todoIdParamSchema.parse(request.params);
      const data = await service.getById(businessId, id);
      return sendData(reply, data);
    },

    update: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const businessId = requireBusinessId(request);
        const { id } = todoIdParamSchema.parse(request.params);
        const body = updateTodoBodySchema.parse(request.body);
        const data = await service.update(businessId, id, body);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid request body',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    delete: async (request: FastifyRequest, reply: FastifyReply) => {
      const businessId = requireBusinessId(request);
      const { id } = todoIdParamSchema.parse(request.params);
      await service.delete(businessId, id);
      return reply.status(204).send();
    },
  };
}
