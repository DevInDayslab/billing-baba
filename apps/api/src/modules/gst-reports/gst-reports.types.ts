export type GstReportWarning = {
  code: string;
  message: string;
  count: number;
  document_ids?: string[];
};

export type GstReportMeta = {
  period: string;
  from: string;
  to: string;
  business_id: string;
  generated_at: string;
  flags: {
    non_tax_as_exempt?: boolean;
    financial_year?: string;
    discontinued_filing?: boolean;
    disclaimer?: string;
  };
};

export type GstReportSection = {
  key: string;
  title: string;
  rows: Record<string, unknown>[];
  totals?: Record<string, string>;
};

export type GstReportEnvelope = {
  meta: GstReportMeta;
  sections: GstReportSection[];
  totals: Record<string, string>;
  warnings: GstReportWarning[];
};
