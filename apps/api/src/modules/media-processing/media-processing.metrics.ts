export type MediaProcessingMetricsSnapshot = {
  totalProcessed: number;
  totalFailed: number;
  totalSkipped: number;
  totalOriginalBytes: number;
  totalOptimizedBytes: number;
  totalVariantsGenerated: number;
  totalDurationMs: number;
};

export class MediaProcessingMetrics {
  private snapshot: MediaProcessingMetricsSnapshot = {
    totalProcessed: 0,
    totalFailed: 0,
    totalSkipped: 0,
    totalOriginalBytes: 0,
    totalOptimizedBytes: 0,
    totalVariantsGenerated: 0,
    totalDurationMs: 0,
  };

  recordSuccess(input: {
    originalSize: number;
    optimizedSize: number;
    variantCount: number;
    durationMs: number;
  }): void {
    this.snapshot.totalProcessed += 1;
    this.snapshot.totalOriginalBytes += input.originalSize;
    this.snapshot.totalOptimizedBytes += input.optimizedSize;
    this.snapshot.totalVariantsGenerated += input.variantCount;
    this.snapshot.totalDurationMs += input.durationMs;
  }

  recordFailure(): void {
    this.snapshot.totalFailed += 1;
  }

  recordSkipped(): void {
    this.snapshot.totalSkipped += 1;
  }

  getSnapshot(): MediaProcessingMetricsSnapshot {
    return { ...this.snapshot };
  }

  getAverageCompressionPercent(): number | null {
    if (this.snapshot.totalOriginalBytes === 0) return null;
    const ratio =
      this.snapshot.totalOptimizedBytes / this.snapshot.totalOriginalBytes;
    return Math.round((1 - ratio) * 10000) / 100;
  }

  getAverageLatencyMs(): number | null {
    if (this.snapshot.totalProcessed === 0) return null;
    return Math.round(
      this.snapshot.totalDurationMs / this.snapshot.totalProcessed,
    );
  }
}

export const globalMediaProcessingMetrics = new MediaProcessingMetrics();
