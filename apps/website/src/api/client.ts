const API_ORIGIN = (
  import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:3000'
).replace(/\/$/, '');

const API_V1_BASE = `${API_ORIGIN}/api/v1`;

export type ApiError = {
  code: string;
  message: string;
};

export class ApiRequestError extends Error {
  constructor(
    public readonly status: number,
    public readonly code: string,
    message: string,
  ) {
    super(message);
    this.name = 'ApiRequestError';
  }
}

type ApiFetchOptions = RequestInit & {
  /** Absolute path under /api/v1, e.g. /collaboration/invitations/:token */
  basePath?: string;
};

export async function apiFetch<T>(
  path: string,
  init?: ApiFetchOptions,
): Promise<T> {
  const method = (init?.method ?? 'GET').toUpperCase();
  const hasBody = init?.body != null;
  const needsJsonBody =
    !hasBody && (method === 'POST' || method === 'PUT' || method === 'PATCH');

  const { basePath, ...fetchInit } = init ?? {};
  const root = basePath ? `${API_V1_BASE}${basePath}` : `${API_V1_BASE}/collaboration`;

  const response = await fetch(`${root}${path}`, {
    ...fetchInit,
    method,
    body: hasBody ? fetchInit.body : needsJsonBody ? '{}' : undefined,
    headers: {
      ...(needsJsonBody || hasBody ? { 'content-type': 'application/json' } : {}),
      ...fetchInit.headers,
    },
  });

  const body = (await response.json().catch(() => ({}))) as {
    data?: T;
    error?: ApiError;
  };

  if (!response.ok) {
    throw new ApiRequestError(
      response.status,
      body.error?.code ?? 'UNKNOWN_ERROR',
      body.error?.message ?? 'Something went wrong',
    );
  }

  return body.data as T;
}
