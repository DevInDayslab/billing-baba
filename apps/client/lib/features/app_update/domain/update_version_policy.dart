import 'package:pub_semver/pub_semver.dart';

/// Whether the manifest describes a release newer than the installed app.
///
/// An update is offered when **either** [remoteBuild] is greater than
/// [currentBuild], **or** [remoteVersion] is a higher semver than
/// [currentVersion] (e.g. 1.0.1 vs 1.0.0).
bool isRemoteReleaseNewer({
  required String remoteVersion,
  required int remoteBuild,
  required String currentVersion,
  required int currentBuild,
}) {
  if (remoteBuild > currentBuild) return true;

  final remote = _tryParseVersion(remoteVersion);
  final current = _tryParseVersion(currentVersion);
  if (remote != null && current != null) {
    return remote > current;
  }

  return false;
}

Version? _tryParseVersion(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  try {
    return Version.parse(trimmed);
  } on FormatException {
    return null;
  }
}
