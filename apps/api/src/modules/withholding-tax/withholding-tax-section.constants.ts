type ApplicableOn = 'sale' | 'purchase' | 'payment_in' | 'payment_out';
type Kind = 'tds' | 'tcs';

export type PreloadedWithholdingSection = {
  kind: Kind;
  code: string;
  description: string;
  rate: string;
  applicableOn: ApplicableOn;
};

/** Preloaded TDS/TCS section master rows for new businesses. */
export const PRELOADED_WITHHOLDING_SECTIONS: PreloadedWithholdingSection[] = [
  {
    kind: 'tds',
    code: '194C',
    description: 'Contractors and subcontractors',
    rate: '1.0000',
    applicableOn: 'payment_out',
  },
  {
    kind: 'tds',
    code: '194H',
    description: 'Commission or brokerage',
    rate: '5.0000',
    applicableOn: 'payment_out',
  },
  {
    kind: 'tds',
    code: '194I',
    description: 'Rent — property (default)',
    rate: '10.0000',
    applicableOn: 'payment_out',
  },
  {
    kind: 'tds',
    code: '194J',
    description: 'Professional or technical services',
    rate: '10.0000',
    applicableOn: 'payment_out',
  },
  {
    kind: 'tds',
    code: '194Q',
    description: 'Purchase of goods',
    rate: '0.1000',
    applicableOn: 'purchase',
  },
  {
    kind: 'tcs',
    code: '206C(1H)',
    description: 'Sale of goods',
    rate: '0.1000',
    applicableOn: 'sale',
  },
  {
    kind: 'tcs',
    code: '206C(1)',
    description: 'Alcoholic liquor for human consumption',
    rate: '1.0000',
    applicableOn: 'sale',
  },
];
