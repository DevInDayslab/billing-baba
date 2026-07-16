const LOG_PREFIX = '[PurchaseParse]';

function formatError(error: unknown): { message: string; stack: string | undefined } {
  if (error instanceof Error) {
    return { message: error.message, stack: error.stack };
  }
  return { message: String(error), stack: undefined };
}

export function logGeminiGenerateContentStart(model: string): number {
  const startedAt = performance.now();
  console.info(`${LOG_PREFIX} Gemini generateContent start model=${model}`);
  return startedAt;
}

export function logGeminiGenerateContentEnd(
  model: string,
  startedAt: number,
): void {
  const latencyMs = Math.round(performance.now() - startedAt);
  console.info(
    `${LOG_PREFIX} Gemini generateContent end model=${model} latencyMs=${latencyMs}`,
  );
}

export function logGeminiRawResponseText(text: string | undefined | null): void {
  if (text == null || text.trim() === '') {
    console.warn(`${LOG_PREFIX} Gemini response.text is empty or missing`);
    return;
  }

  console.info(
    `${LOG_PREFIX} Gemini response.text (length=${text.length}): ${text}`,
  );
}

export function logJsonParseError(
  stage: string,
  error: unknown,
  sourceText?: string,
): void {
  const { message, stack } = formatError(error);
  console.error(
    `${LOG_PREFIX} JSON parse failed stage=${stage} error=${message}`,
  );
  if (stack) {
    console.error(`${LOG_PREFIX} JSON parse stack:\n${stack}`);
  }
  if (sourceText !== undefined) {
    console.error(
      `${LOG_PREFIX} JSON parse source (length=${sourceText.length}): ${sourceText}`,
    );
  }
}

export function logGeminiParsedJson(parsed: unknown): void {
  console.info(
    `${LOG_PREFIX} Gemini parsed JSON (before normalization): ${JSON.stringify(parsed)}`,
  );
}

export function logNormalizationInput(raw: unknown): void {
  console.info(
    `${LOG_PREFIX} Normalization input: ${JSON.stringify(raw)}`,
  );
}

export function logFlattenedDocument(flattened: unknown): void {
  console.info(
    `${LOG_PREFIX} Flattened document (before Zod validation): ${JSON.stringify(flattened)}`,
  );
}

export function logNormalizedDocument(document: unknown): void {
  console.info(
    `${LOG_PREFIX} Normalized purchase document: ${JSON.stringify(document)}`,
  );
}

export function logValidationOrMappingError(
  stage: string,
  error: unknown,
  context?: unknown,
): void {
  const { message, stack } = formatError(error);
  console.error(
    `${LOG_PREFIX} ${stage} failed error=${message}`,
  );
  if (stack) {
    console.error(`${LOG_PREFIX} ${stage} stack:\n${stack}`);
  }
  if (context !== undefined) {
    console.error(
      `${LOG_PREFIX} ${stage} context: ${JSON.stringify(context)}`,
    );
  }
}
