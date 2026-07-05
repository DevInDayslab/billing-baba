type OpenApiOperation = Record<string, unknown>;
type OpenApiPathItem = Record<string, OpenApiOperation>;
type OpenApiDoc = {
  paths: OpenApiPathItem;
  tags?: Array<{ name: string; description?: string }>;
  [key: string]: unknown;
};

/** Canonical tag catalog — order defines Swagger UI display order. */
export const TAG_CATALOG: Array<{ name: string; description: string }> = [
  { name: 'Health', description: 'Service health and readiness probes.' },
  {
    name: 'Authentication',
    description: 'Login, refresh, logout, and session management.',
  },
  {
    name: 'Business',
    description: 'Business onboarding, profile, and membership.',
  },
  {
    name: 'Dashboard',
    description: 'Business KPI dashboard and summary metrics.',
  },
  { name: 'Parties', description: 'Customers, suppliers, and contacts.' },
  {
    name: 'Inventory',
    description: 'Products, services, stock, catalog, and warehouses.',
  },
  {
    name: 'Pricing',
    description: 'Tier-based pricing for items and parties.',
  },
  {
    name: 'Sales',
    description: 'Sales documents — estimates, invoices, orders, and returns.',
  },
  {
    name: 'POS',
    description: 'Point-of-sale register sessions and document numbering.',
  },
  {
    name: 'Purchases',
    description: 'Purchase bills, orders, returns, and fixed assets.',
  },
  {
    name: 'Payments',
    description: 'Payment receipts, payouts, and document allocations.',
  },
  {
    name: 'Expenses',
    description: 'Business expenses and expense categories.',
  },
  {
    name: 'Reports',
    description: 'Business, stock, party, and financial reports.',
  },
  {
    name: 'GST',
    description: 'GST returns (GSTR-1/2/3B/9), TCS, and TDS reports.',
  },
  {
    name: 'Job Work',
    description: 'Manufacturing and job-work orders.',
  },
];

const HTTP_METHODS = new Set([
  'get',
  'post',
  'put',
  'patch',
  'delete',
  'head',
  'options',
]);

/** Normalize paths — collapse /path and /path/ duplicates; prefer no trailing slash. */
export function normalizePaths(
  paths: OpenApiPathItem,
): OpenApiPathItem {
  const normalized: OpenApiPathItem = {};

  for (const [rawPath, methods] of Object.entries(paths)) {
    const canonical = rawPath.replace(/\/+$/, '') || '/';
    if (normalized[canonical]) {
      normalized[canonical] = { ...normalized[canonical], ...methods };
    } else {
      normalized[canonical] = { ...methods };
    }
  }

  return normalized;
}

/** Collect tags actually used by operations; drop empty / default tags. */
export function deriveActiveTags(
  paths: OpenApiPathItem,
): Array<{ name: string; description: string }> {
  const used = new Set<string>();

  for (const methods of Object.values(paths)) {
    for (const [method, operation] of Object.entries(methods)) {
      if (!HTTP_METHODS.has(method)) continue;
      const op = operation as OpenApiOperation;
      const tags = (op.tags as string[] | undefined) ?? [];
      for (const tag of tags) {
        if (tag && tag !== 'default') used.add(tag);
      }
    }
  }

  return TAG_CATALOG.filter((tag) => used.has(tag.name));
}

/** Ensure every operation has exactly one tag and no 'default' tag. */
export function sanitizeOperationTags(paths: OpenApiPathItem): OpenApiPathItem {
  const result: OpenApiPathItem = {};

  for (const [path, methods] of Object.entries(paths)) {
    result[path] = {};
    for (const [method, operation] of Object.entries(methods)) {
      if (!HTTP_METHODS.has(method)) {
        result[path][method] = operation;
        continue;
      }
      const op = operation as OpenApiOperation;
      const tags = ((op.tags as string[]) ?? []).filter(
        (t) => t && t !== 'default',
      );
      result[path][method] = {
        ...op,
        tags: tags.length > 0 ? [tags[0]] : op.tags,
      };
    }
  }

  return result;
}

export function polishOpenApiDocument(doc: OpenApiDoc): OpenApiDoc {
  let paths = normalizePaths(doc.paths);
  paths = sanitizeOperationTags(paths);
  const tags = deriveActiveTags(paths);

  return {
    ...doc,
    paths,
    tags,
  };
}
