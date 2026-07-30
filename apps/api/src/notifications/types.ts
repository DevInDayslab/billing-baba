export type NotificationDeepLinks = {
  primary?: string;
  [key: string]: string | undefined;
};

/**
 * Provider-agnostic notification content.
 * Providers only receive the rendered body string via sendText().
 */
export type NotificationContent = {
  type: string;
  title: string;
  body: string;
  metadata: Record<string, unknown>;
  deepLinks: NotificationDeepLinks;
};

export function renderTemplate(
  template: string,
  vars: Record<string, string | number | null | undefined>,
): string {
  return template.replace(/\{\{(\w+)\}\}/g, (_match, key: string) => {
    const value = vars[key];
    if (value == null) return '';
    return String(value);
  });
}

export function formatInrAmount(amount: string | number): string {
  const numeric =
    typeof amount === 'number' ? amount : Number.parseFloat(amount);
  if (Number.isNaN(numeric)) {
    return String(amount);
  }
  return numeric.toLocaleString('en-IN', {
    minimumFractionDigits: 0,
    maximumFractionDigits: 2,
  });
}
