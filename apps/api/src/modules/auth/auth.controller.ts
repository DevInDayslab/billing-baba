import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import type { AppConfig } from '../../config/app_config';
import { AppError } from '../../shared/errors/app-error';
import type { ApiSuccessResponse } from '../../shared/types';
import {
  loginBodySchema,
  logoutBodySchema,
  refreshBodySchema,
} from './auth.schema';
import { AuthService } from './auth.service';
import type {
  AuthSessionResponse,
  JwtAccessPayload,
  MeResponse,
} from './auth.types';

function formatZodError(error: ZodError): Record<string, string[]> {
  const errors: Record<string, string[]> = {};
  for (const issue of error.issues) {
    const path = issue.path.join('.') || 'body';
    errors[path] = errors[path] ?? [];
    errors[path].push(issue.message);
  }
  return errors;
}

export function createAuthController(config: AppConfig) {
  return {
    login: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<ApiSuccessResponse<AuthSessionResponse>> => {
      try {
        const body = loginBodySchema.parse(request.body);
        const service = new AuthService(request.server, config);
        const data = await service.login(body.access_token, body.phone);
        return reply.send({ success: true, data });
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

    refresh: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<ApiSuccessResponse<AuthSessionResponse>> => {
      try {
        const body = refreshBodySchema.parse(request.body);
        const service = new AuthService(request.server, config);
        const data = await service.refresh(
          body.refresh_token,
          body.business_id,
        );
        return reply.send({ success: true, data });
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

    logout: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<ApiSuccessResponse<{ message: string }>> => {
      try {
        const body = logoutBodySchema.parse(request.body);
        const service = new AuthService(request.server, config);
        await service.logout(body.refresh_token);
        return reply.send({
          success: true,
          data: { message: 'Logged out successfully' },
        });
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

    me: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<ApiSuccessResponse<MeResponse>> => {
      const payload = request.user as JwtAccessPayload;
      const service = new AuthService(request.server, config);
      const data = await service.getMe(payload);
      return reply.send({ success: true, data });
    },

    devLogin: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ): Promise<ApiSuccessResponse<AuthSessionResponse>> => {
      const service = new AuthService(request.server, config);
      const data = await service.devLogin();
      return reply.send({ success: true, data });
    },
  };
}
