import type { FastifyReply } from 'fastify';

function escapeCsvValue(value: unknown): string {
  if (value === null || value === undefined) {
    return '';
  }
  const text = String(value);
  if (/[",\n\r]/.test(text)) {
    return `"${text.replace(/"/g, '""')}"`;
  }
  return text;
}

export function rowsToCsv(rows: Record<string, unknown>[]): string {
  if (rows.length === 0) {
    return '';
  }

  const headers = Object.keys(rows[0] ?? {});
  const lines = [
    headers.join(','),
    ...rows.map((row) =>
      headers.map((header) => escapeCsvValue(row[header])).join(','),
    ),
  ];
  return lines.join('\n');
}

export function sendCsv(
  reply: FastifyReply,
  filename: string,
  rows: Record<string, unknown>[],
): FastifyReply {
  const csv = rowsToCsv(rows);
  return reply
    .header('Content-Type', 'text/csv; charset=utf-8')
    .header('Content-Disposition', `attachment; filename="${filename}"`)
    .status(200)
    .send(csv);
}
