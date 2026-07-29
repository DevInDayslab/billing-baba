import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SyncActivityKind {
  info,
  success,
  warning,
  error,
}

class SyncActivityEntry {
  const SyncActivityEntry({
    required this.message,
    required this.timestamp,
    this.kind = SyncActivityKind.info,
  });

  final String message;
  final DateTime timestamp;
  final SyncActivityKind kind;
}

final syncActivityLogProvider =
    NotifierProvider<SyncActivityLogNotifier, List<SyncActivityEntry>>(
  SyncActivityLogNotifier.new,
);

class SyncActivityLogNotifier extends Notifier<List<SyncActivityEntry>> {
  static const _maxEntries = 50;

  @override
  List<SyncActivityEntry> build() => const [];

  void add(
    String message, {
    SyncActivityKind kind = SyncActivityKind.info,
    DateTime? at,
  }) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;
    if (state.isNotEmpty && state.first.message == trimmed) return;

    final next = [
      SyncActivityEntry(
        message: trimmed,
        timestamp: at ?? DateTime.now(),
        kind: kind,
      ),
      ...state,
    ];
    state = next.length > _maxEntries
        ? next.sublist(0, _maxEntries)
        : next;
  }

  void clear() => state = const [];
}
