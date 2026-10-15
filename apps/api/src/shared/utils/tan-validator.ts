const TAN_REGEX = /^[A-Z]{4}[0-9]{5}[A-Z]$/;

export function normalizeTan(value: string): string {
  return value.trim().toUpperCase();
}

export function isValidTan(value: string | null | undefined): boolean {
  if (!value?.trim()) return false;
  return TAN_REGEX.test(normalizeTan(value));
}
