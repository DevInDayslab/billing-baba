import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';

/// Dashboard data plus offline/cache metadata for the UI layer.
class DashboardViewState {
  const DashboardViewState({
    required this.dashboard,
    this.isCachedSnapshot = false,
    this.snapshotSavedAt,
    this.isRefreshing = false,
  });

  final DashboardModel dashboard;
  final bool isCachedSnapshot;
  final DateTime? snapshotSavedAt;
  final bool isRefreshing;

  DashboardViewState copyWith({
    DashboardModel? dashboard,
    bool? isCachedSnapshot,
    DateTime? snapshotSavedAt,
    bool? isRefreshing,
    bool clearSnapshotSavedAt = false,
  }) {
    return DashboardViewState(
      dashboard: dashboard ?? this.dashboard,
      isCachedSnapshot: isCachedSnapshot ?? this.isCachedSnapshot,
      snapshotSavedAt:
          clearSnapshotSavedAt ? null : (snapshotSavedAt ?? this.snapshotSavedAt),
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}
