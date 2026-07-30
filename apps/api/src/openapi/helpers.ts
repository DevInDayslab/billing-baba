import type { ZodTypeAny } from 'zod';
import { zodToJsonSchema } from 'zod-to-json-schema';

export function zodSchema(
  schema: ZodTypeAny,
  name?: string,
): Record<string, unknown> {
  return zodToJsonSchema(schema as never, {
    name,
    $refStrategy: 'none',
    target: 'openApi3',
  }) as Record<string, unknown>;
}

export function ref(name: string): { $ref: string } {
  return { $ref: `#/components/schemas/${name}` };
}

export const bearerAuth = {
  bearerAuth: {
    type: 'http' as const,
    scheme: 'bearer',
    bearerFormat: 'JWT',
    description:
      'JWT access token from POST /auth/login or POST /auth/dev-login (development only). Include as `Authorization: Bearer <token>`.',
  },
};

export const businessHeaderNote =
  'Requires a valid JWT whose payload includes `business_id` for the selected business.';

export const paginationQueryProperties = {
  page: {
    type: 'integer',
    minimum: 1,
    default: 1,
    description: 'Page number (1-based).',
    example: 1,
  },
  limit: {
    type: 'integer',
    minimum: 1,
    maximum: 100,
    default: 20,
    description: 'Items per page.',
    example: 20,
  },
};

export const paginationMetaSchema = {
  type: 'object',
  required: ['page', 'limit', 'total', 'totalPages'],
  properties: {
    page: { type: 'integer', example: 1 },
    limit: { type: 'integer', example: 20 },
    total: { type: 'integer', example: 100 },
    totalPages: { type: 'integer', example: 5 },
  },
};

export const errorResponseSchema = {
  type: 'object',
  required: ['error', 'requestId'],
  properties: {
    error: {
      type: 'object',
      required: ['code', 'message'],
      properties: {
        code: { type: 'string', example: 'VALIDATION_ERROR' },
        message: { type: 'string', example: 'Invalid request body' },
        details: {
          type: 'object',
          additionalProperties: {
            type: 'array',
            items: { type: 'string' },
          },
          example: { name: ['Name is required'] },
        },
      },
    },
    requestId: { type: 'string', example: 'req-abc123' },
  },
};

export const errorExample = {
  error: {
    code: 'VALIDATION_ERROR',
    message: 'Invalid request body',
    details: { name: ['Name is required'] },
  },
  requestId: 'req-abc123',
};

export const unauthorizedExample = {
  error: { code: 'UNAUTHORIZED', message: 'Missing or invalid token' },
  requestId: 'req-abc123',
};

export const notFoundExample = {
  error: { code: 'NOT_FOUND', message: 'Resource not found' },
  requestId: 'req-abc123',
};

export const conflictExample = {
  error: { code: 'CONFLICT', message: 'Resource already exists' },
  requestId: 'req-abc123',
};

export function paginatedResponseSchema(itemRef: { $ref: string }) {
  return {
    type: 'object',
    required: ['data', 'meta'],
    properties: {
      data: {
        type: 'array',
        items: itemRef,
      },
      meta: paginationMetaSchema,
    },
  };
}

export function dataResponseSchema(itemRef: { $ref: string }) {
  return {
    type: 'object',
    required: ['data'],
    properties: {
      data: itemRef,
    },
  };
}

export const standardErrorResponses = {
  400: {
    description: 'Validation error — invalid request body or query parameters',
    content: {
      'application/json': {
        schema: errorResponseSchema,
        example: errorExample,
      },
    },
  },
  401: {
    description: 'Unauthorized — missing or invalid JWT',
    content: {
      'application/json': {
        schema: errorResponseSchema,
        example: unauthorizedExample,
      },
    },
  },
  403: {
    description:
      'Forbidden — no access to this business or insufficient permissions',
    content: {
      'application/json': {
        schema: errorResponseSchema,
        example: {
          error: {
            code: 'FORBIDDEN',
            message: 'No access to this business',
          },
          requestId: 'req-abc123',
        },
      },
    },
  },
  404: {
    description: 'Resource not found',
    content: {
      'application/json': {
        schema: errorResponseSchema,
        example: notFoundExample,
      },
    },
  },
  409: {
    description: 'Conflict — duplicate or state conflict',
    content: {
      'application/json': {
        schema: errorResponseSchema,
        example: conflictExample,
      },
    },
  },
  422: {
    description: 'Business rule violation',
    content: {
      'application/json': {
        schema: errorResponseSchema,
        example: {
          error: {
            code: 'BUSINESS_RULE_VIOLATION',
            message: 'Cannot finalize a cancelled document',
          },
          requestId: 'req-abc123',
        },
      },
    },
  },
  500: {
    description: 'Internal server error',
    content: {
      'application/json': {
        schema: errorResponseSchema,
        example: {
          error: {
            code: 'INTERNAL_ERROR',
            message: 'An unexpected error occurred',
          },
          requestId: 'req-abc123',
        },
      },
    },
  },
};

export function securedOperation(
  operation: Record<string, unknown>,
): Record<string, unknown> {
  const description = operation.description as string | undefined;
  const businessNote = businessHeaderNote;
  const fullDescription = description
    ? `${description}\n\n**Permissions:** ${businessNote}`
    : `**Permissions:** ${businessNote}`;

  return {
    security: [{ bearerAuth: [] }],
    ...operation,
    description: fullDescription,
  };
}

export function unsecuredOperation(
  operation: Record<string, unknown>,
): Record<string, unknown> {
  return operation;
}

type OpenApiParameter = {
  name: string;
  in: 'query' | 'path' | 'header';
  required?: boolean;
  description?: string;
  schema: Record<string, unknown>;
  example?: unknown;
};

function stripSchemaMeta(
  prop: Record<string, unknown>,
): Record<string, unknown> {
  const { $schema: _, ...rest } = prop;
  return rest;
}

/** Convert a Zod object schema to OpenAPI query parameters. */
export function queryParamsFromZod(
  schema: ZodTypeAny,
  name: string,
): OpenApiParameter[] {
  const json = zodSchema(schema, name);
  const properties = (json.properties ?? {}) as Record<
    string,
    Record<string, unknown>
  >;
  const required = (json.required ?? []) as string[];

  return Object.entries(properties).map(([paramName, propSchema]) => ({
    name: paramName,
    in: 'query' as const,
    required: required.includes(paramName),
    description: (propSchema.description as string | undefined) ?? undefined,
    schema: stripSchemaMeta(propSchema),
    ...(propSchema.example !== undefined
      ? { example: propSchema.example }
      : propSchema.default !== undefined
        ? { example: propSchema.default }
        : {}),
  }));
}

/** Convert a Zod object schema to OpenAPI path parameters. */
export function pathParamsFromZod(
  schema: ZodTypeAny,
  name: string,
): OpenApiParameter[] {
  const json = zodSchema(schema, name);
  const properties = (json.properties ?? {}) as Record<
    string,
    Record<string, unknown>
  >;
  const required = (json.required ?? []) as string[];

  return Object.entries(properties).map(([paramName, propSchema]) => ({
    name: paramName,
    in: 'path' as const,
    required: required.includes(paramName) || true,
    description: (propSchema.description as string | undefined) ?? undefined,
    schema: stripSchemaMeta(propSchema),
  }));
}

export function jsonRequestBody(
  schemaRef: string,
  examples?: Record<string, { summary: string; value: unknown }>,
): Record<string, unknown> {
  const content: Record<string, unknown> = {
    'application/json': {
      schema: ref(schemaRef),
      ...(examples ? { examples } : {}),
    },
  };
  return { required: true, content };
}

export function optionalJsonRequestBody(
  schemaRef: string,
  examples?: Record<string, { summary: string; value: unknown }>,
): Record<string, unknown> {
  const content: Record<string, unknown> = {
    'application/json': {
      schema: ref(schemaRef),
      ...(examples ? { examples } : {}),
    },
  };
  return { required: false, content };
}

export function okResponse(
  description: string,
  schemaRef: string,
  example?: unknown,
): Record<string, unknown> {
  return {
    description,
    content: {
      'application/json': {
        schema: dataResponseSchema(ref(schemaRef)),
        ...(example !== undefined ? { example: { data: example } } : {}),
      },
    },
  };
}

export function okPaginatedResponse(
  description: string,
  schemaRef: string,
): Record<string, unknown> {
  return {
    description,
    content: {
      'application/json': {
        schema: paginatedResponseSchema(ref(schemaRef)),
      },
    },
  };
}

export function okEmptyResponse(description: string): Record<string, unknown> {
  return {
    description,
    content: {
      'application/json': {
        schema: { type: 'object', properties: { data: { type: 'object' } } },
      },
    },
  };
}

export function createdResponse(
  description: string,
  schemaRef: string,
  example?: unknown,
): Record<string, unknown> {
  return {
    description,
    content: {
      'application/json': {
        schema: dataResponseSchema(ref(schemaRef)),
        ...(example !== undefined ? { example: { data: example } } : {}),
      },
    },
  };
}

export function noContentResponse(
  description: string,
): Record<string, unknown> {
  return { description };
}

export const genericObjectSchema = {
  type: 'object' as const,
  additionalProperties: true,
};

export const reportDataSchema = {
  type: 'object' as const,
  additionalProperties: true,
  description: 'Report payload — structure varies by report type.',
};

export const reportPaginatedDataSchema = {
  type: 'object' as const,
  properties: {
    rows: {
      type: 'array',
      items: { type: 'object', additionalProperties: true },
    },
    summary: { type: 'object', additionalProperties: true },
  },
  additionalProperties: true,
};
