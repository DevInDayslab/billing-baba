/// Guards pull appliers from overwriting newer local rows with stale server data.
bool shouldApplyPullChange({
  required int incomingSyncVersion,
  required int? existingSyncVersion,
  required bool isDeleted,
}) {
  final existing = existingSyncVersion ?? 0;
  if (incomingSyncVersion > existing) return true;
  if (isDeleted && incomingSyncVersion >= existing) return true;
  return false;
}
