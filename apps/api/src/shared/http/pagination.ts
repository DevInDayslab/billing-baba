export type PaginationInput = {
  page: number;
  limit: number;
  total: number;
};

export type PaginationMeta = {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
};

export function buildPaginationMeta(input: PaginationInput): PaginationMeta {
  const totalPages =
    input.total === 0 ? 0 : Math.ceil(input.total / input.limit);

  return {
    page: input.page,
    limit: input.limit,
    total: input.total,
    totalPages,
  };
}
