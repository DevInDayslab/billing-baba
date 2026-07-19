import type { AppConfig } from '../config/app_config';
import { bearerAuth } from './helpers';
import {
  buildAccountingPaths,
  buildDashboardPaths,
  buildJobWorkPaths,
} from './paths/accounting-dashboard.paths';
import { buildCollaborationPaths } from './paths/collaboration.paths';
import {
  buildAuthPaths,
  buildBusinessPaths,
  buildHealthPaths,
} from './paths/core.paths';
import {
  buildInventoryPaths,
  buildPartiesPaths,
} from './paths/parties-inventory.paths';
import { buildPurchasesPaths } from './paths/purchases.paths';
import { buildReportsPaths } from './paths/reports.paths';
import { buildSalesPaths } from './paths/sales.paths';
import { polishOpenApiDocument } from './polish';
import { buildSchemas } from './schemas';

export function buildOpenApiDocument(config: AppConfig) {
  const schemas = buildSchemas();

  const paths = {
    ...buildHealthPaths(),
    ...buildAuthPaths(config),
    ...buildBusinessPaths(),
    ...buildPartiesPaths(),
    ...buildInventoryPaths(),
    ...buildSalesPaths(),
    ...buildPurchasesPaths(),
    ...buildAccountingPaths(),
    ...buildDashboardPaths(),
    ...buildReportsPaths(),
    ...buildJobWorkPaths(),
    ...buildCollaborationPaths(),
  };

  const draft = {
    openapi: '3.1.0',
    info: {
      title: config.appName,
      version: config.version,
      description: [
        'Billing Baba REST API — offline-first POS, billing, inventory, and business management for Indian SMBs.',
        '',
        '## Quick start',
        '1. `POST /auth/login` with MSG91 token (or `POST /auth/dev-login` in development)',
        '2. Click **Authorize** and paste `Bearer <access_token>`',
        '3. Call business-scoped endpoints with your active `business_id` in the JWT',
        '',
        '## Authentication',
        'Protected endpoints require `Authorization: Bearer <access_token>`.',
        'Refresh via `POST /auth/refresh`. Switch business by passing `business_id` in the refresh body.',
        '',
        '## Response envelope',
        '- Single resource: `{ "data": { ... } }`',
        '- Paginated list: `{ "data": [...], "meta": { "page", "limit", "total", "totalPages" } }`',
        '',
        '## Errors',
        '`{ "error": { "code", "message", "details?" }, "requestId" }`',
        '',
        '| Code | HTTP | Meaning |',
        '|------|------|---------|',
        '| `VALIDATION_ERROR` | 400 | Invalid body or query |',
        '| `UNAUTHORIZED` | 401 | Missing or invalid JWT |',
        '| `FORBIDDEN` | 403 | No access to business |',
        '| `NOT_FOUND` | 404 | Resource not found |',
        '| `CONFLICT` | 409 | Duplicate or state conflict |',
        '| `BUSINESS_RULE_VIOLATION` | 422 | Business rule failed |',
      ].join('\n'),
      contact: {
        name: 'Billing Baba API Support',
        url: 'https://billingbaba.com',
      },
    },
    servers: [
      { url: config.apiPrefix, description: `${config.environment} API` },
    ],
    tags: [],
    components: {
      securitySchemes: bearerAuth,
      schemas,
    },
    paths,
  };

  return polishOpenApiDocument(draft);
}
