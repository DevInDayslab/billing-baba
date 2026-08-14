/// Merges party group names into a sorted, case-insensitively unique list.
///
/// The first occurrence wins for casing (e.g. stored "Retail" beats "retail").
List<String> mergePartyGroupNames(Iterable<String> names) {
  final byKey = <String, String>{};
  for (final name in names) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) continue;
    final key = trimmed.toLowerCase();
    byKey.putIfAbsent(key, () => trimmed);
  }
  return byKey.values.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
}

bool partyGroupNamesEqual(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool partyGroupNameExists(List<String> groups, String name) {
  final key = name.trim().toLowerCase();
  if (key.isEmpty) return false;
  return groups.any((group) => group.toLowerCase() == key);
}
