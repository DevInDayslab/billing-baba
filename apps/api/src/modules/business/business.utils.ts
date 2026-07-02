/** Indian GST state / UT codes for business registration. */
export const STATE_NAME_TO_CODE: Record<string, string> = {
  Delhi: '07',
  Maharashtra: '27',
  Karnataka: '29',
  'Tamil Nadu': '33',
  'Uttar Pradesh': '09',
  Gujarat: '24',
  Rajasthan: '08',
  'West Bengal': '19',
  'Madhya Pradesh': '23',
  'Andhra Pradesh': '37',
  Telangana: '36',
  Kerala: '32',
  Punjab: '03',
  Haryana: '06',
  Bihar: '10',
  Odisha: '21',
  Assam: '18',
  Jharkhand: '20',
  Uttarakhand: '05',
  'Himachal Pradesh': '02',
  Goa: '30',
  Chhattisgarh: '22',
};

export function resolveStateCode(
  state?: string,
  stateCode?: string,
): string {
  if (stateCode?.trim()) {
    return stateCode.trim();
  }
  if (state?.trim()) {
    return STATE_NAME_TO_CODE[state.trim()] ?? '27';
  }
  return '27';
}

export function resolveStateName(stateCode: string): string | null {
  const entry = Object.entries(STATE_NAME_TO_CODE).find(
    ([, code]) => code === stateCode,
  );
  return entry?.[0] ?? null;
}

export function currentFiscalYearLabel(): string {
  const now = new Date();
  const month = now.getMonth() + 1;
  const year = now.getFullYear();
  // Indian FY starts April; label as ending year e.g. FY 2025-26 → "2026"
  return month >= 4 ? String(year + 1) : String(year);
}
