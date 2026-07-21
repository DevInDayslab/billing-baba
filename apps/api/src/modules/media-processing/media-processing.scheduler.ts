import type { MediaProcessingService } from './media-processing.service';

type ScheduleInput = {
  businessId: string | null;
  accountId: string;
  assetId: string;
};

export function scheduleMediaProcessing(
  service: MediaProcessingService,
  input: ScheduleInput,
): void {
  void (async () => {
    try {
      await service.processAsset(
        input.businessId,
        input.accountId,
        input.assetId,
      );
    } catch {
      // Errors are logged inside MediaProcessingService.
    }
  })();
}
