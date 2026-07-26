/// Builds sync protocol headers for SyncClient.
abstract class SyncHeaderProvider {
  Future<Map<String, String>> build({
    required String deviceId,
    required String appVersion,
  });
}

class DefaultSyncHeaderProvider implements SyncHeaderProvider {
  const DefaultSyncHeaderProvider({this.protocolVersion = '1'});

  final String protocolVersion;

  @override
  Future<Map<String, String>> build({
    required String deviceId,
    required String appVersion,
  }) async {
    return {
      'X-Device-Id': deviceId,
      'X-App-Version': appVersion,
      'X-Sync-Protocol-Version': protocolVersion,
    };
  }
}
