import type { GstReportWarning } from '../gst-reports.types';

export class WarningCollector {
  private readonly buckets = new Map<
    string,
    { message: string; documentIds: Set<string> }
  >();

  add(code: string, message: string, documentId?: string | null): void {
    const existing = this.buckets.get(code);
    if (!existing) {
      const set = new Set<string>();
      if (documentId) set.add(documentId);
      this.buckets.set(code, { message, documentIds: set });
      return;
    }
    if (documentId) existing.documentIds.add(documentId);
  }

  toArray(): GstReportWarning[] {
    return [...this.buckets.entries()].map(([code, bucket]) => ({
      code,
      message: bucket.message,
      count: bucket.documentIds.size,
      document_ids:
        bucket.documentIds.size > 0
          ? [...bucket.documentIds].slice(0, 50)
          : undefined,
    }));
  }
}
