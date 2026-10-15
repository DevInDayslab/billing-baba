import type { GstReportEnvelope } from '../gst-reports.types';

/** Best-effort GSTN offline tool JSON for GSTR-3B (verify against portal utility). */
export function mapGstr3bToGstnJson(
  envelope: GstReportEnvelope,
): Record<string, unknown> {
  return {
    gstin: '',
    ret_period: envelope.meta.from.slice(0, 7).replace('-', ''),
    sup_details: envelope.sections.find((s) => s.key === 'table_3_1')?.rows,
    inter_sup: envelope.sections.find((s) => s.key === 'table_3_2')?.rows,
    itc_elg: envelope.sections.find((s) => s.key === 'table_4')?.rows,
    tax_paid: envelope.sections.find((s) => s.key === 'table_6_1')?.rows,
    warnings: envelope.warnings,
  };
}
