/// Wire values stored in Drift `sync_queue.kind`.
enum SyncQueueKind {
  row('row'),
  command('command'),
  media('media');

  const SyncQueueKind(this.wire);
  final String wire;

  static SyncQueueKind fromWire(String value) {
    return SyncQueueKind.values.firstWhere(
      (e) => e.wire == value,
      orElse: () => SyncQueueKind.row,
    );
  }
}

/// Wire values stored in Drift `sync_queue.operation`.
enum SyncQueueOperation {
  create('create'),
  update('update'),
  delete('delete'),
  command('command'),
  uploadMedia('upload_media');

  const SyncQueueOperation(this.wire);
  final String wire;

  static SyncQueueOperation fromWire(String value) {
    return SyncQueueOperation.values.firstWhere(
      (e) => e.wire == value,
      orElse: () => SyncQueueOperation.create,
    );
  }
}

/// Wire values stored in Drift `sync_queue.status`.
enum SyncQueueStatus {
  pending('pending'),
  running('running'),
  completed('completed'),
  failed('failed'),
  conflict('conflict'),
  cancelled('cancelled');

  const SyncQueueStatus(this.wire);
  final String wire;

  static SyncQueueStatus fromWire(String value) {
    return SyncQueueStatus.values.firstWhere(
      (e) => e.wire == value,
      orElse: () => SyncQueueStatus.pending,
    );
  }
}

/// Lower int = higher priority (consumed first).
enum SyncQueuePriority {
  high(0),
  normal(1),
  low(2);

  const SyncQueuePriority(this.value);
  final int value;

  static SyncQueuePriority fromValue(int value) {
    return SyncQueuePriority.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SyncQueuePriority.normal,
    );
  }
}
