import type { AppConfig } from '../../config/app_config';
import {
  authExamples,
  businessExamples,
  responseExamples,
} from '../examples';
import {
  dataResponseSchema,
  okResponse,
  ref,
  standardErrorResponses,
  unsecuredOperation,
} from '../helpers';
import { publicPostOperation } from '../operations';
import { Schema } from '../schema-names';

export function buildHealthPaths() {
  return {
    '/health': {
      get: unsecuredOperation({
        tags: ['Health'],
        summary: 'Health Check',
        description:
          'Returns service status, version, and uptime. No authentication required. Use for load balancer probes.',
        operationId: 'getHealth',
        responses: {
          200: {
            description: 'Service is healthy',
            content: {
              'application/json': {
                schema: dataResponseSchema(ref(Schema.HealthResponse)),
                example: { data: responseExamples.health },
              },
            },
          },
        },
      }),
    },
    '/ready': {
      get: unsecuredOperation({
        tags: ['Health'],
        summary: 'Readiness Probe',
        description:
          'Kubernetes-style readiness check. Returns the same payload as `/health`. No authentication required.',
        operationId: 'getReady',
        responses: {
          200: {
            description: 'Service is ready to accept traffic',
            content: {
              'application/json': {
                schema: dataResponseSchema(ref(Schema.HealthResponse)),
                example: { data: responseExamples.health },
              },
            },
          },
        },
      }),
    },
    '/health/db': {
      get: unsecuredOperation({
        tags: ['Health'],
        summary: 'Database Health',
        description:
          'Checks PostgreSQL connectivity. Returns HTTP 503 when the database is unreachable.',
        operationId: 'getDatabaseHealth',
        responses: {
          200: {
            description: 'Database reachable',
            content: {
              'application/json': {
                schema: dataResponseSchema(ref(Schema.DatabaseHealthResponse)),
                example: { data: { database: 'connected' } },
              },
            },
          },
          503: {
            description: 'Database unreachable',
            content: {
              'application/json': {
                schema: dataResponseSchema(ref(Schema.DatabaseHealthResponse)),
                example: { data: { database: 'disconnected' } },
              },
            },
          },
        },
      }),
    },
  };
}

export function buildAuthPaths(config: AppConfig) {
  return {
    '/auth/login': {
      post: publicPostOperation({
        tag: 'Authentication',
        summary: 'Login',
        description:
          'Exchanges an MSG91 widget access token for JWT session tokens. Creates an account on first login.\n\n**Note:** Phone number may be required if MSG91 omits it from the token.',
        operationId: 'login',
        bodyRef: Schema.LoginRequest,
        responseRef: Schema.AuthSessionResponse,
        examples: authExamples.login,
        responseExample: responseExamples.authSession,
      }),
    },
    '/auth/refresh': {
      post: publicPostOperation({
        tag: 'Authentication',
        summary: 'Refresh Session',
        description:
          'Issues new access and refresh tokens. Optionally switch active business via `business_id`.',
        operationId: 'refreshSession',
        bodyRef: Schema.RefreshSessionRequest,
        responseRef: Schema.AuthSessionResponse,
        examples: authExamples.refresh,
        responseExample: responseExamples.authSession,
      }),
    },
    '/auth/logout': {
      post: {
        tags: ['Authentication'],
        summary: 'Logout',
        description: 'Revokes the refresh token. Requires a valid Bearer JWT.',
        operationId: 'logout',
        security: [{ bearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: ref(Schema.LogoutRequest),
              examples: authExamples.logout,
            },
          },
        },
        responses: {
          200: okResponse('Logged out successfully', Schema.AuthSessionResponse),
          ...standardErrorResponses,
        },
      },
    },
    '/auth/me': {
      get: {
        tags: ['Authentication'],
        summary: 'Get Current User',
        description:
          'Returns the authenticated user profile and all business memberships.',
        operationId: 'getCurrentUser',
        security: [{ bearerAuth: [] }],
        responses: {
          200: okResponse('User profile and memberships', Schema.MeResponse),
          ...standardErrorResponses,
        },
      },
    },
    ...(config.enableDevLogin
      ? {
          '/auth/dev-login': {
            post: unsecuredOperation({
              tags: ['Authentication'],
              summary: 'Development Login',
              description:
                '**Development only** (`ENABLE_DEV_LOGIN=true`). Bypasses MSG91 OTP and issues a real JWT session. Never available in production.',
              operationId: 'devLogin',
              responses: {
                200: okResponse(
                  'Development session issued',
                  Schema.AuthSessionResponse,
                  responseExamples.authSession,
                ),
              },
            }),
          },
        }
      : {}),
  };
}

export function buildBusinessPaths() {
  return {
    '/businesses': {
      get: {
        tags: ['Business'],
        summary: 'List Businesses',
        description:
          'Returns all businesses the authenticated user has access to.',
        operationId: 'listBusinesses',
        security: [{ bearerAuth: [] }],
        responses: {
          200: okResponse('Business list', Schema.BusinessResponse),
          ...standardErrorResponses,
        },
      },
      post: {
        tags: ['Business'],
        summary: 'Create Business',
        description:
          'Onboards a new business. The authenticated user becomes the owner.',
        operationId: 'createBusiness',
        security: [{ bearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: ref(Schema.CreateBusinessRequest),
              examples: businessExamples.createBusiness,
            },
          },
        },
        responses: {
          201: okResponse('Business created', Schema.BusinessResponse),
          ...standardErrorResponses,
        },
      },
    },
    '/business/profile': {
      get: {
        tags: ['Business'],
        summary: 'Get Business Profile',
        description:
          'Returns the active business profile (from JWT `business_id`).',
        operationId: 'getBusinessProfile',
        security: [{ bearerAuth: [] }],
        responses: {
          200: okResponse('Business profile', Schema.BusinessProfileResponse),
          ...standardErrorResponses,
        },
      },
      put: {
        tags: ['Business'],
        summary: 'Update Business Profile',
        description: 'Updates fields on the active business profile.',
        operationId: 'updateBusinessProfile',
        security: [{ bearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: ref(Schema.UpdateBusinessProfileRequest),
              examples: businessExamples.updateProfile,
            },
          },
        },
        responses: {
          200: okResponse('Updated profile', Schema.BusinessProfileResponse),
          ...standardErrorResponses,
        },
      },
    },
  };
}
