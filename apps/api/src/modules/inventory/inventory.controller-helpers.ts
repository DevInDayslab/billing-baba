import type { FastifyRequest } from 'fastify';
import type { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';

export function formatZodError(error: ZodError): Record<string, string[]> {
  const errors: Record<string, string[]> = {};
  for (const issue of error.issues) {
    const path = issue.path.join('.') || 'body';
    errors[path] = errors[path] ?? [];
    errors[path].push(issue.message);
  }
  return errors;
}

export function requireAuthContext(request: FastifyRequest): {
  accountId: string;
  businessId: string;
  userId?: string;
} {
  const accountId = request.accountId;
  const businessId = request.businessId;
  if (!accountId || !businessId) {
    throw new AppError(
      'UNAUTHORIZED',
      'Account or business not found in token',
      401,
    );
  }

  return {
    accountId,
    businessId,
    userId: request.userId,
  };
}
