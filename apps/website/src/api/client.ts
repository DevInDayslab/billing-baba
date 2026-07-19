const API_ORIGIN = (
  import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:3000'
).replace(/\/$/, '');

const COLLABORATION_API_BASE = `${API_ORIGIN}/api/v1/collaboration`;

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

export async function apiFetch<T>(
  path: string,
  init?: RequestInit,
): Promise<T> {
  const method = (init?.method ?? 'GET').toUpperCase();
  const hasBody = init?.body != null;
  const needsJsonBody =
    !hasBody && (method === 'POST' || method === 'PUT' || method === 'PATCH');

  const response = await fetch(`${COLLABORATION_API_BASE}${path}`, {
    ...init,
    method,
    body: hasBody ? init.body : needsJsonBody ? '{}' : undefined,
    headers: {
      ...(needsJsonBody || hasBody ? { 'content-type': 'application/json' } : {}),
      ...init?.headers,
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
