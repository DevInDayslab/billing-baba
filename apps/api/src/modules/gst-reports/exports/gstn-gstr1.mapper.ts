import type { GstReportEnvelope } from '../gst-reports.types';

/** Best-effort GSTN offline tool JSON for GSTR-1 (verify against portal utility). */
export function mapGstr1ToGstnJson(
  envelope: GstReportEnvelope,
): Record<string, unknown> {
  const section = (key: string) =>
    envelope.sections.find((s) => s.key === key)?.rows ?? [];

  return {
    gstin: '',
    fp: envelope.meta.from.slice(0, 7).replace('-', ''),
    b2b: section('b2b'),
    b2cl: section('b2cl'),
    b2cs: section('b2cs'),
    cdnr: section('cdnr'),
    cdnur: section('cdnur'),
    exp: section('exports'),
    nil: section('nil_exempt'),
    hsn: section('hsn_summary'),
    doc_issue: section('doc_issue'),
    warnings: envelope.warnings,
  };
}
