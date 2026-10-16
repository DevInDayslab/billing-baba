/// Signaled when an invalidated async provider build must not surface as UI error.
class AsyncProviderStaleBuild implements Exception {
  const AsyncProviderStaleBuild();
}

bool isAsyncProviderStaleError(Object error) {
  if (error is AsyncProviderStaleBuild) return true;
  final text = error.toString();
  return text.contains('after it has been disposed');
}
