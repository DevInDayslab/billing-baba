/** Map line unit text to GST UQC code (simplified). */
export function mapUnitToUqc(unit: string): string {
  const normalized = unit.trim().toLowerCase();
  const map: Record<string, string> = {
    piece: 'PCS',
    pcs: 'PCS',
    pc: 'PCS',
    kg: 'KGS',
    kgs: 'KGS',
    gram: 'GMS',
    gms: 'GMS',
    g: 'GMS',
    litre: 'LTR',
    ltr: 'LTR',
    l: 'LTR',
    meter: 'MTR',
    mtr: 'MTR',
    box: 'BOX',
    dozen: 'DOZ',
    doz: 'DOZ',
    unit: 'UNT',
    unt: 'UNT',
  };
  return map[normalized] ?? 'OTH';
}
