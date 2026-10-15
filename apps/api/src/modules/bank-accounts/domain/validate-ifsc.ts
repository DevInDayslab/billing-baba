const IFSC_PATTERN = /^[A-Z]{4}0[A-Z0-9]{6}$/;

export function validateIfsc(value: string | null | undefined): boolean {
  if (value == null || value.trim() === '') {
    return true;
  }
  return IFSC_PATTERN.test(value.trim().toUpperCase());
}

export function normalizeIfsc(value: string): string {
  return value.trim().toUpperCase();
}
