/// Parsed update manifest from public hosting (never GitHub).
class AppUpdateInfo {
  const AppUpdateInfo({
    required this.latestVersion,
    required this.latestBuild,
    required this.minSupportedBuild,
    required this.installerUrl,
    required this.sha256,
    required this.releaseNotes,
    required this.forceUpdate,
    this.publishedAt,
  });

  final String latestVersion;
  final int latestBuild;
  final int minSupportedBuild;
  final String installerUrl;
  final String sha256;
  final String releaseNotes;
  final bool forceUpdate;
  final DateTime? publishedAt;

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    final latestVersion = _requireString(json, 'latest_version');
    final latestBuild = _requireInt(json, 'latest_build');
    final minSupportedBuild = _requireInt(json, 'min_supported_build');
    final installerUrl = _requireString(json, 'installer_url');
    final sha256 = _requireString(json, 'sha256');
    final releaseNotes = _requireString(json, 'release_notes');
    final forceUpdate = json['force_update'];
    if (forceUpdate is! bool) {
      throw FormatException('Invalid or missing force_update');
    }

    DateTime? publishedAt;
    final publishedRaw = json['published_at'];
    if (publishedRaw != null) {
      if (publishedRaw is! String || publishedRaw.trim().isEmpty) {
        throw FormatException('Invalid published_at');
      }
      publishedAt = DateTime.parse(publishedRaw);
    }

    if (latestVersion.trim().isEmpty) {
      throw FormatException('Invalid latest_version');
    }
    if (installerUrl.trim().isEmpty) {
      throw FormatException('Invalid installer_url');
    }
    if (sha256.trim().isEmpty) {
      throw FormatException('Invalid sha256');
    }

    return AppUpdateInfo(
      latestVersion: latestVersion.trim(),
      latestBuild: latestBuild,
      minSupportedBuild: minSupportedBuild,
      installerUrl: installerUrl.trim(),
      sha256: sha256.trim(),
      releaseNotes: releaseNotes,
      forceUpdate: forceUpdate,
      publishedAt: publishedAt,
    );
  }

  static String _requireString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String) {
      throw FormatException('Invalid or missing $key');
    }
    return value;
  }

  static int _requireInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    throw FormatException('Invalid or missing $key');
  }
}
