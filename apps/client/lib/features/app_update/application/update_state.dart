import 'package:billing_baba/features/app_update/domain/app_update_info.dart';

enum UpdateStatus {
  idle,
  checking,
  upToDate,
  updateAvailable,
  checkingSafety,
  backingUp,
  downloading,
  verifying,
  readyToInstall,
  installing,
  error,
}

class UpdateState {
  const UpdateState({
    this.status = UpdateStatus.idle,
    this.updateInfo,
    this.isForced = false,
    this.downloadProgress,
    this.receivedBytes,
    this.totalBytes,
    this.errorMessage,
    this.canRetry = false,
    this.hardBlocks = const [],
    this.softBlocks = const [],
    this.awaitingSoftBlockConfirm = false,
  });

  final UpdateStatus status;
  final AppUpdateInfo? updateInfo;
  final bool isForced;
  final double? downloadProgress;
  final int? receivedBytes;
  final int? totalBytes;
  final String? errorMessage;
  final bool canRetry;
  final List<String> hardBlocks;
  final List<String> softBlocks;
  final bool awaitingSoftBlockConfirm;

  UpdateState copyWith({
    UpdateStatus? status,
    AppUpdateInfo? updateInfo,
    bool? isForced,
    double? downloadProgress,
    int? receivedBytes,
    int? totalBytes,
    String? errorMessage,
    bool? canRetry,
    List<String>? hardBlocks,
    List<String>? softBlocks,
    bool? awaitingSoftBlockConfirm,
    bool clearUpdateInfo = false,
    bool clearError = false,
    bool clearProgress = false,
  }) {
    return UpdateState(
      status: status ?? this.status,
      updateInfo: clearUpdateInfo ? null : (updateInfo ?? this.updateInfo),
      isForced: isForced ?? this.isForced,
      downloadProgress: clearProgress
          ? null
          : (downloadProgress ?? this.downloadProgress),
      receivedBytes: clearProgress
          ? null
          : (receivedBytes ?? this.receivedBytes),
      totalBytes: clearProgress ? null : (totalBytes ?? this.totalBytes),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      canRetry: canRetry ?? this.canRetry,
      hardBlocks: hardBlocks ?? this.hardBlocks,
      softBlocks: softBlocks ?? this.softBlocks,
      awaitingSoftBlockConfirm:
          awaitingSoftBlockConfirm ?? this.awaitingSoftBlockConfirm,
    );
  }
}
